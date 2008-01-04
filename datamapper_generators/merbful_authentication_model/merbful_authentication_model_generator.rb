class MerbfulAuthenticationModelGenerator < RubiGen::Base

  attr_reader   :name,  
                :class_name, 
                :class_path, 
                :file_name, 
                :class_nesting, 
                :class_nesting_depth, 
                :plural_name, 
                :singular_name,
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
      m.class_collisions [], 'AuthenticatedSystem::OrmMap'
      
      m.directory File.join('app/models', class_path)
      m.directory File.join('lib')
      
      m.template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
      m.template 'authenticated_system_orm_map.rb', "lib/authenticated_system_orm_map.rb"         
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