require 'active_support/inflector'

Pry::Commands.create_command "define-it", "Commands for code generation reported during a Pry session for use in TDD" do

  def process
    last_exception = context[:pry_instance].last_exception
    if last_exception.class == NameError
      klass = last_exception.name.to_s
      code  = "class #{klass}\n\nend"
      file  = "#{klass.underscore}.rb"

      File.open(file, 'w') { |f| f.write(code) }

      silence_warnings do
        TOPLEVEL_BINDING.eval(File.read(file), file)                                                                                                     
      end

      throw :try_again
    elsif last_exception.class == NoMethodError
      klass  = last_exception.message.match(/<(.*):/)[1]
      method = last_exception.name.to_s
      args   = last_exception.args.each_with_index.map { |arg,i| "#{arg.class.to_s.downcase}#{i}" }

      method_def = "  def #{method}(#{args.join(',')})\n     \n  end"

      file = Pry::CodeObject.lookup(klass,_pry_).source_file
      file = `ack #{klass} *.rb`.split(':')[0] unless file

      lines = File.readlines(file).size
      code  = File.read(file).gsub(/^end/mi) { |match| "#{method_def}\n\n#{match}" }
      
      File.open(file, 'w') { |f| f.write(code) }

      run "edit -r -l #{lines+1} #{file}"
    end
  end
end
