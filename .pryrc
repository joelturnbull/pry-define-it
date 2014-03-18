require 'active_support/inflector'

Pry::Commands.create_command "define-it", "Commands for generating missing code reported during a Pry session for use in TDD" do

  def process
    last_exception = context[:pry_instance].last_exception
    if last_exception.class == NameError
      klass = last_exception.name.to_s
      code = "class #{klass}\n\nend"
      file = "#{klass.underscore}.rb"

      File.open(file, 'w') {|f| f.write(code) }

      silence_warnings do
        TOPLEVEL_BINDING.eval(File.read(file), file)                                                                                                     
      end

      throw :try_again
    end
  end
end
