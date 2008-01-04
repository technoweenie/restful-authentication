class MerbfulAuthenticationTestsGenerator < RubiGen::Base
  
  attr_reader   :name,  
                :class_name, 
                :class_path, 
                :file_name, 
                :class_nesting, 
                :class_nesting_depth, 
                :plural_name, 
                :singular_name,
                :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name,
                :model_controller_name,
                :model_controller_class_path,
                :model_controller_file_path,
                :model_controller_class_nesting,
                :model_controller_class_nesting_depth,
                :model_controller_class_name,
                :model_controller_singular_name,
                :model_controller_plural_name,
                :include_activation
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    extract_options
    runtime_options.each{ |k,v| self.instance_variable_set("@#{k}", v) }    
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory "test"
      m.directory "test/unit"
      m.directory "test/functional"
      
      m.directory "test/mailers" if include_activation
      # Create stubs
      m.template "model_test_helper.rb", File.join("test",  "#{file_name}_test_helper.rb")
      m.template "authenticated_system_test_helper.rb", File.join("test", "authenticated_system_test_helper.rb")
      m.template "model_functional_test.rb", File.join("test", "functional", "#{model_controller_file_path}_test.rb")
      m.template "functional_test.rb", File.join("test", "functional", "#{controller_file_path}_test.rb")
      m.template "unit_test.rb", File.join("test", "unit", "#{singular_name}_test.rb")
    
      if include_activation
        m.template "mailer_test.rb", File.join("test/mailers", "#{singular_name}_mailer_test.rb")
      end
    end
  end

  protected
    def banner
      <<-EOS
Creates a ...

USAGE: #{$0} #{spec.name} name"
EOS
    end

    def add_options!(opts)
      # opts.separator ''
      # opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |options[:author]| }
      # opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
end