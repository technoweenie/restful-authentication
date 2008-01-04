require 'merb'
class AuthenticationGenerator < RubiGen::Base
  
  default_options :author => nil
  
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
                :controller_plural_name
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name
  attr_reader   :model_controller_name,
                :model_controller_class_path,
                :model_controller_file_path,
                :model_controller_class_nesting,
                :model_controller_class_nesting_depth,
                :model_controller_class_name,
                :model_controller_singular_name,
                :model_controller_plural_name
  alias_method  :model_controller_file_name,  :model_controller_singular_name
  alias_method  :model_controller_table_name, :model_controller_plural_name
  attr_reader   :include_activation
  
  def initialize(runtime_args, runtime_options = {})
    usage if runtime_args.empty?
    super
    extract_options
    assign_names!(runtime_args.shift)
    @include_activation = options[:include_activation]
    
    @controller_name = runtime_args.shift || 'sessions'
    @model_controller_name = @name.pluralize
    @mailer_controller_name = @name
    
    # sessions controller
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end

    # model controller
    base_name, @model_controller_class_path, @model_controller_file_path, @model_controller_class_nesting, @model_controller_class_nesting_depth = extract_modules(@model_controller_name)
    @model_controller_class_name_without_nesting, @model_controller_singular_name, @model_controller_plural_name = inflect_names(base_name)
    
    if @model_controller_class_nesting.empty?
      @model_controller_class_name = @model_controller_class_name_without_nesting
    else
      @model_controller_class_name = "#{@model_controller_class_nesting}::#{@model_controller_class_name_without_nesting}"
    end    
  end

  def manifest
    manifest_result = record do |m|
      # Check for class naming collisions.
      m.class_collisions controller_class_path,       "#{controller_class_name}", # Sessions Controller
                                                      "Merb::#{controller_class_name}Helper"
      m.class_collisions model_controller_class_path, "#{model_controller_class_name}", # Model Controller
                                                      "Merb::#{model_controller_class_name}Helper"
      m.class_collisions class_path,                  "#{class_name}", "#{class_name}Mailer"# , "#{class_name}MailerTest", "#{class_name}Observer"
      m.class_collisions [], 'AuthenticatedSystem::Controller', 'AuthenticatedSystem::Model'

      # Controller, helper, views, and test directories.
      
      m.directory File.join('app/controllers', controller_class_path)
      m.directory File.join('app/controllers', model_controller_class_path)
      
      m.directory File.join('app/helpers', controller_class_path)
      m.directory File.join('app/views', controller_class_path, controller_file_name)
      
      m.directory File.join('app/controllers', model_controller_class_path)
      m.directory File.join('app/helpers', model_controller_class_path)
      m.directory File.join('app/views', model_controller_class_path, model_controller_file_name)
      
      # Generate the authenticated system" libraries
      m.directory "lib"
      m.template "authenticated_system_controller.rb",  "lib/authenticated_system_controller.rb"
      m.template "authenticated_system_model.rb",       "lib/authenticated_system_model.rb"
      
      # Mailer directory for activation
      if options[:include_activation]
        m.directory File.join('app/mailers/views', "#{singular_name}_mailer")
        m.template  "mail_controller.rb",       File.join('app/mailers', 
                                                          "#{singular_name}_mailer.rb")
        [:html, :text].each do |format|
          [:signup, :activation].each do |action|
            m.template "#{action}.#{format}.erb",   File.join('app/mailers/views',
                                                              "#{singular_name}_mailer",
                                                              "#{action}_notification.#{format}.erb")
          end
        end
      end
      
      # Generate the model
      model_attributes = { 
        :class_name           => class_name,
        :class_path           => class_path, 
        :file_name            => file_name, 
        :class_nesting        => class_nesting, 
        :class_nesting_depth  => class_nesting_depth, 
        :plural_name          => plural_name, 
        :singular_name        => singular_name,
        :include_activation   => options[:include_activation]     
      }
      m.dependency "merbful_authentication_model", [name], model_attributes 

      # Generate the sessions controller
      m.template "session_controller.rb", File.join('app/controllers', 
                                                    controller_class_path, 
                                                    "#{controller_file_name}.rb")
      
      # Generate the model controller
      m.template "model_controller.rb",   File.join('app/controllers',
                                                    model_controller_class_path,
                                                    "#{model_controller_file_name}.rb")
                                                    
      # Controller templates
      m.template 'login.html.erb',  File.join('app/views', controller_class_path, controller_file_name, "new.html.erb")
      m.template 'new_model.html.erb', File.join('app/views', model_controller_class_path, model_controller_file_name, "new.html.erb")
      
      
      controller_attributes = {
        :controller_name                          => controller_name,
        :controller_class_path                    => controller_class_path,
        :controller_file_path                     => controller_file_path,
        :controller_class_nesting                 => controller_class_nesting,
        :controller_class_nesting_depth           => controller_class_nesting_depth,
        :controller_class_name                    => controller_class_name,
        :controller_singular_name                 => controller_singular_name,
        :controller_plural_name                   => controller_plural_name,
        :model_controller_name                    => model_controller_name,
        :model_controller_class_path              => model_controller_class_path,
        :model_controller_file_path               => model_controller_file_path,
        :model_controller_class_nesting           => model_controller_class_nesting,
        :model_controller_class_nesting_depth     => model_controller_class_nesting_depth,
        :model_controller_class_name              => model_controller_class_name,
        :model_controller_singular_name           => model_controller_singular_name,
        :model_controller_plural_name             => model_controller_plural_name,
        :include_activation                       => options[:include_activation]
      }
      # Generate the tests
      m.dependency "merbful_authentication_tests", [name], model_attributes.dup.merge!(controller_attributes)
    end
    
    action = nil
    action = $0.split("/")[1]
    case action
    when 'generate'
      puts finishing_message
    when 'destroy'
      puts "Thanx for using merbful_authentication"
    end
    
    manifest_result
    
  end

  protected
  # Override with your own usage banner.
  def banner
    out = <<-EOD;
    Usage: #{$0} authenticated ModelName [ControllerName]  
    EOD
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-migration", 
           "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
    opt.on("--include-activation", 
           "Generate signup 'activation code' confirmation via email") { |v| options[:include_activation] = true }
  end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
    
    
    # Borrowed from RailsGenerators
    # Extract modules from filesystem-style or ruby-style path:
    #   good/fun/stuff
    #   Good::Fun::Stuff
    # produce the same results.
    def extract_modules(name)
      modules = name.include?('/') ? name.split('/') : name.split('::')
      name    = modules.pop
      path    = modules.map { |m| m.underscore }
      file_path = (path + [name.underscore]).join('/')
      nesting = modules.map { |m| m.camelize }.join('::')
      [name, path, file_path, nesting, modules.size]
    end
    
    def inflect_names(name)
      camel  = name.camelize
      under  = camel.underscore
      plural = under.pluralize
      [camel, under, plural]
    end
    
    def assign_names!(name)
      @name = name
      base_name, @class_path, @file_name, @class_nesting, @class_nesting_depth = extract_modules(@name)
      @class_name_without_nesting, @singular_name, @plural_name = inflect_names(base_name)
      @table_name = @name.pluralize
      # @table_name = (!defined?(ActiveRecord::Base) || ActiveRecord::Base.pluralize_table_names) ? plural_name : singular_name
      @table_name.gsub! '/', '_'
      if @class_nesting.empty?
        @class_name = @class_name_without_nesting
      else
        @table_name = @class_nesting.underscore << "_" << @table_name
        @class_name = "#{@class_nesting}::#{@class_name_without_nesting}"
      end
    end
    
    private 
    
    def finishing_message
      output = <<-EOD
#{"-" * 70}
Don't forget to:
    
  - add named routes for authentication.  These are currently required
    In config/router.rb
    
      r.resources :#{plural_name}
      r.match("/login").to(:controller => "#{controller_class_name}", :action => "create").name(:login)
      r.match("/logout").to(:controller => "#{controller_class_name}", :action => "destroy").name(:logout)
EOD
    if options[:include_activation]
      output << "      r.match(\"/#{plural_name}/activate/:activation_code\").to(:controller => \"#{model_controller_class_name}\", :action => \"activate\").name(:#{singular_name}_activation)"
    end
    
    output << "\n\n" << ("-" * 70)
  end

    
end