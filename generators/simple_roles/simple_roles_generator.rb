class EmailVerificationGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false,
                  :skip_routes    => false,
                  :old_passwords  => false,
                  :include_activation => false

  attr_reader :model_path,
    :parent_model_name,
    :parent_plural_name,
    :parent_table_name,         # users db table
    :parent_class_name,         # User class name
    :parent_model_path,         # models/user
    :parent_controller_name,    # users_controller
    :parent_controller_path     # controllers/users_controller

  def initialize(runtime_args, runtime_options = {})
    super
    @default_roles_list     = [:user, ]
    @parent_model_name      = "user"
    @parent_plural_name     = @parent_model_name.pluralize
    @parent_table_name      = @parent_model_name.pluralize
    @parent_class_name      = @parent_model_name.classify
    @parent_model_path      = "models/#{@parent_model_name}"
    @parent_controller_name = "#{@parent_plural_name}_controller"
    @parent_controller_path = "controllers/#{@parent_controller_name}"
    @model_path             = "#{parent_model_name}/email_verification"
  end

  def manifest
    record do |m|
      # m.directory "lib"
      m.directory File.join('app/views', parent_model_path, 'email_verification')
      m.directory File.join('app',  @parent_controller_path)
      m.directory File.join('app',  @parent_model_path)
      m.directory File.join('spec', @parent_controller_path)
      m.directory File.join('spec', @parent_model_path)

      add_user_model_concerns m
      add_users_controller_concerns m
      add_migration m unless options[:skip_migration]
      post_install_notes
    end
  end

  protected
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} email_verification User"
  end
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    # opt.on("--tests",
    #   "Force test generation (else skipped if rspecs generated)") { |v| options[:tests] = true }
    # opt.on("--rspec",
    #   "Force rspec mode (checks for RAILS_ROOT/spec by default)") { |v| options[:rspec] = true }
    # opt.on("--no-rspec",
    #   "Force no rspecs created")                                  { |v| options[:rspec] = false }
    opt.on("--quiet",
      "Skip the post-install notes)")                             { |v| options[:quiet] = v }
    # opt.on("--skip-routes",
    #   "Don't generate a resource line in config/routes.rb")       { |v| options[:skip_routes] = v }
    # opt.on("--skip-migration",
    #   "Don't generate a migration file for this model")           { |v| options[:skip_migration] = v }
    # opt.on("--dump-generator-attrs",
    #   "(generator debug helper)")                                 { |v| options[:dump_generator_attribute_names] = v }
  end

  #
  # Installation methods
  #

  def add_users_controller_concerns m
    dest_file = "email_verification.rb"
    src_file  = "email_verification_controller.rb"
    dest_path = File.join('app', parent_controller_path, dest_file)
    puts "templating #{src_file} to #{dest_path}"
    m.template src_file, dest_path
  end

  def add_user_model_concerns m
    %w[observer mailer].each do |concern|
      src_file  = "email_verification_#{concern}.rb"
      dest_file = src_file
      dest_path = File.join('app', parent_model_path, dest_file)
      puts "templating #{src_file} to #{dest_path}"
      m.template src_file, dest_path
    end
  end

  def add_migration m
    migration_class_name   = "add_#{model_path}_columns".camelize.gsub(/::/, '')
    migration_file_name    = migration_class_name.underscore

    m.migration_template 'migration.rb', 'db/migrate', :assigns => {
       :migration_name      => migration_class_name
    }, :migration_file_name => migration_file_name
  end

  #
  # Post-install notes
  #
  def post_install_notes
    return if options[:quiet]
    action = File.basename($0) # grok the action from './script/generate' or whatever
    case action
    when "generate"
      puts "- Add an observer to config/environment.rb"
      puts "    config.active_record.observers = :#{file_name}_observer"
    end
    puts %{ map.verify '/verify/:activation_code', :controller => '#{parent_controller_name}', :action => 'verify_email', :verification_code => nil }
  end

end
# def manifest
#   record do |m|
#     modify_or_add_user_fixtures(m)
#     add_roles_and_join_table_fixtures(m)
#
#     add_method_to_user_model(m)
#
#     add_role_model(m)
#     add_dependencies_to_application_rb
#     add_dependencies_to_test_helper_rb
#     add_role_requirement_system(m)
#     add_migration(m) unless options[:skip_migration]
#   end
# end
#
# def add_role_model(m)
#   # add the Role model
#   m.template 'role_model.rb.erb', roles_model_filename
# end
#
# def add_method_to_user_model(m)
#   content_for_insertion = render_template("_user_functions.erb")
#   # modify the User model unless it's already got RoleRequirement code in there
#   if insert_content_after(users_model_filename,
#                     Regexp.new("class +#{users_model_name}"),
#                     content_for_insertion,
#                     :unless => lambda { |content| content.include? "def has_role?"; }
#                     )
#     puts "Added the following to the top of #{users_model_filename}:\n#{content_for_insertion}"
#   else
#     puts "Not modifying #{users_model_filename} because it appears that the funtion has_role? already exists."
#   end
# end

