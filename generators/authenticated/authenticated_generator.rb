require File.expand_path(File.dirname(__FILE__) + "/../lib/insert_routes.rb")
require 'digest/sha1'
class AuthenticatedGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false,
                  :skip_routes    => false,
                  :old_passwords  => false,
                  :include_activation => false

  attr_reader   :model_controller_name,
                :model_controller_class_path,
                :model_controller_file_path,
                :model_controller_class_nesting,
                :model_controller_class_nesting_depth,
                :model_controller_class_name,
                :model_controller_singular_name,
                :model_controller_plural_name,
                :model_controller_controller_name,
                :model_controller_routing_path,
                :model_controller_routing_name,
                :fixtures_name,
                :model_name

  alias_method  :model_controller_file_name,  :model_controller_singular_name
  alias_method  :model_controller_table_name, :model_controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super

    @rspec = has_rspec?
    options[:tests] ||= ! options[:rspec]

    #
    # Set up users controller names
    #
    @model_controller_name = @name.pluralize
    @model_name = file_name

    base_name, @model_controller_class_path, @model_controller_file_path,
      @model_controller_class_nesting, @model_controller_class_nesting_depth =
      extract_modules(@model_controller_name)

    @model_controller_class_name_without_nesting,
      @model_controller_singular_name, @model_controller_plural_name =
      inflect_names(base_name)

    if @model_controller_class_nesting.empty?
      @model_controller_class_name = @model_controller_class_name_without_nesting
    else
      @model_controller_class_name = "#{@model_controller_class_nesting}::#{@model_controller_class_name_without_nesting}"
    end
    # functional names
    @fixtures_name = @table_name
    @model_controller_routing_path = @model_controller_file_path
    @model_controller_routing_name = @table_name
    @model_controller_controller_name = @model_controller_plural_name
    #
    # Get existing site keys, so we don't tromp over them.
    #
    load_or_initialize_site_keys()
    if options[:dump_generator_attribute_names]
      dump_generator_attribute_names
    end
  end

  def template_spec m, dir, src, nesting_path, dest
    spec_file = File.join(*["spec", dir, nesting_path, "#{dest}_spec.rb"].compact)
    m.directory File.dirname(spec_file)
    m.template  "spec/#{dir}/#{src}_spec.rb", spec_file
  end

  def controller_spec m, src, nesting_path, dest, routing_spec=false
    template_spec m, "controllers", "#{src}_controller",         nesting_path, "#{dest}_controller"
    template_spec m, "controllers", "#{src}_controller_routing", nesting_path, "#{dest}_controller_routing"
  end

  def manifest
    recorded_session = record do |m|
      # Check for class naming collisions.
      m.class_collisions model_controller_class_path, "#{model_controller_class_name}Controller", # Users Controller
                                                      "#{model_controller_class_name}Helper"
      # FIXME -- need to update the module names here
      # m.class_collisions [], 'AuthenticationSystem', 'AuthenticationTestHelper'


      m.directory File.join('app/models',           class_path)
      m.directory File.join('app/controllers',      model_controller_class_path)
      m.directory File.join('app/helpers',          model_controller_class_path)
      m.directory File.join('app/views',            model_controller_class_path, model_controller_file_name)
      m.directory File.join('app/views/sessions')
      m.directory File.join('lib')

      # Session

      # Model, Controller, helper, and views.
      m.template 'user.rb',                         File.join('app/models',      class_path,                  "#{model_name}.rb")
      m.template 'users_controller.rb',             File.join('app/controllers', model_controller_class_path, "#{model_controller_file_name}_controller.rb")
      m.template 'sessions_controller.rb',           File.join('app/controllers', "sessions_controller.rb")
      m.template 'users_helper.rb',                 File.join('app/helpers',     model_controller_class_path, "#{model_controller_file_name}_helper.rb")
      m.template 'views/signup.html.erb',           File.join('app/views',       model_controller_class_path, model_controller_file_name, "new.html.erb")
      m.template 'views/login.html.erb',            File.join('app/views',       'sessions',                                               "new.html.erb")
      m.template 'views/_users_hello_or_login.html.erb', File.join('app/views', model_controller_class_path, model_controller_file_name, "_hello_or_login.html.erb")
      m.template 'authentication_test_helper.rb',   File.join('lib',             'authentication_test_helper.rb')
      m.template 'security_policy.rb',              File.join('lib',             'security_policy.rb')

      if @rspec
        # RSpec Specs
        controller_spec m, 'users',               model_controller_class_path, model_controller_file_name, true
        controller_spec m, 'sessions',            nil,                         'sessions',                 true
        template_spec m,   'controllers',         'access_control_test',        nil,                       'access_control_test'
        template_spec m,   'models',              'user',                       class_path,                model_name
        template_spec m,   'models',              'identity_password',          class_path,                'identity_password'
        template_spec m,   'models',              'identity_cookie_token',      class_path,                'identity_cookie_token'
        template_spec m,   'helpers',             'users_helper',               model_controller_class_path, "#{model_controller_file_name}_helper"

        # copied straight across
        %w[ authentication  authentication/by_cookie_token    authentication/by_password
            access_control  access_control/approve_all_users  access_control/login_required
          ].each do |f|
          template_spec m, 'lib', f, nil, f
        end

        m.directory                                 File.join('spec/fixtures',   class_path)
        m.template  "spec/fixtures/users.yml",      File.join('spec/fixtures',   class_path, "#{table_name}.yml")
        m.directory 'stories'
        m.template  'rest_auth_stories.rb',         File.join('stories',         class_path, 'rest_auth_stories.rb')
      end

      if options[:tests]
        m.directory File.join('test/functional',   model_controller_class_path)
        m.directory File.join('test/unit',         class_path)
        m.directory File.join('test/fixtures',     class_path)
        m.template 'test/functional_test.rb',       File.join('test/functional',                              "sessions_controller_test.rb")
        m.template 'test/model_functional_test.rb', File.join('test/functional', model_controller_class_path, "#{model_controller_file_name}_controller_test.rb")
        m.template 'test/unit_test.rb',             File.join('test/unit',       class_path,                  "#{model_name}_test.rb")
        m.template 'spec/fixtures/users.yml',       File.join('test/fixtures',                                "#{table_name}.yml")
      end

      # Support
      m.directory File.dirname(site_keys_file)
      m.template 'site_keys.rb', site_keys_file
      unless options[:skip_routes]
        # Note that this fails for nested classes -- you're on your own with setting up the routes.
        m.route_resource  'session'
        m.route_resources model_controller_plural_name
        m.route_name('signup',   '/signup',   {:controller => model_controller_plural_name, :action => 'new'})
        m.route_name('register', '/register', {:controller => model_controller_plural_name, :action => 'create'})
        m.route_name('login',    '/login',    {:controller => 'sessions', :action => 'new'})
        m.route_name('logout',   '/logout',   {:controller => 'sessions', :action => 'destroy'})
      end

      m.readme 'final_install_tasks.txt'

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
    end

    #
    # Post-install notes
    #
    action = File.basename($0) # grok the action from './script/generate' or whatever
    case action
    when "generate"
      puts_install_msg unless options[:quiet]
    when "destroy"
      puts_destroy_msg
    else
      puts "Didn't understand the action '#{action}' -- you might have missed the 'after running me' instructions."
    end

    #
    # Do the thing
    #
    recorded_session
  end

  def has_rspec?
    spec_dir = File.join(RAILS_ROOT, 'spec')
    options[:rspec] ||= (File.exist?(spec_dir) && File.directory?(spec_dir)) unless (options[:rspec] == false)
  end

  #
  # !! These must match the corresponding routines in by_password.rb !!
  #
  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end
  def make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end
  def password_digest(password, salt)
    digest = $rest_auth_site_key_from_generator
    $rest_auth_digest_stretches_from_generator.times do
      digest = secure_digest(digest, salt, password, $rest_auth_site_key_from_generator)
    end
    digest
  end

  #
  # Try to be idempotent:
  # pull in the existing site key if any,
  # seed it with reasonable defaults otherwise
  #
  def load_or_initialize_site_keys
    case
    when defined? REST_AUTH_SITE_KEY
      if (options[:old_passwords]) && ((! REST_AUTH_SITE_KEY.blank?) || (REST_AUTH_DIGEST_STRETCHES != 1))
        raise "You have a site key, but --old-passwords will overwrite it.  If this is really what you want, move the file #{site_keys_file} and re-run."
      end
      $rest_auth_site_key_from_generator         = REST_AUTH_SITE_KEY
      $rest_auth_digest_stretches_from_generator = REST_AUTH_DIGEST_STRETCHES
    when options[:old_passwords]
      $rest_auth_site_key_from_generator         = nil
      $rest_auth_digest_stretches_from_generator = 1
      $rest_auth_keys_are_new                    = true
    else
      $rest_auth_site_key_from_generator         = make_token
      $rest_auth_digest_stretches_from_generator = 10
      $rest_auth_keys_are_new                    = true
    end
  end
  def site_keys_file
    File.join("config", "initializers", "site_keys.rb")
  end

  protected
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} authenticated User"
  end
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--tests",
      "Force test generation (else skipped if rspecs generated)") { |v| options[:tests] = true }
    opt.on("--rspec",
      "Force rspec mode (checks for RAILS_ROOT/spec by default)") { |v| options[:rspec] = true }
    opt.on("--no-rspec",
      "Force no rspecs created")                                  { |v| options[:rspec] = false }
    opt.on("--quiet",
      "Skip the post-install notes)")                             { |v| options[:quiet] = v }
    opt.on("--skip-routes",
      "Don't generate a resource line in config/routes.rb")       { |v| options[:skip_routes] = v }
    opt.on("--skip-migration",
      "Don't generate a migration file for this model")           { |v| options[:skip_migration] = v }
    opt.on("--old-passwords",
      "Use the older password encryption scheme (see README)")    { |v| options[:old_passwords] = v }
    opt.on("--dump-generator-attrs",
      "(generator debug helper)")                                 { |v| options[:dump_generator_attribute_names] = v }
  end
  def puts_install_msg
    puts "Ready to generate."
    puts ("-" * 70)
    puts
    if $rest_auth_site_key_from_generator.blank?
      puts "You've set a nil site key. This preserves existing users' passwords,"
      puts "but allows dictionary attacks in the unlikely event your database is"
      puts "compromised and your site code is not.  See the README for more."
    elsif $rest_auth_keys_are_new
      puts "We've create a new site key in #{site_keys_file}.  If you have existing"
      puts "user accounts their passwords will no longer work (see README). As always,"
      puts "keep this file safe but don't post it in public."
    else
      puts "We've reused the existing site key in #{site_keys_file}.  As always,"
      puts "keep this file safe but don't post it in public."
    end
    puts
    puts ("-" * 70)
  end
  def puts_destroy_msg
    puts
    puts ("-" * 70)
    puts
    puts "Thanks for using restful_authentication"
    puts
    puts "Don't forget to comment out the observer line in environment.rb"
    puts "  (This was optional so it may not even be there)"
    puts "  # config.active_record.observers = :#{model_name}_observer"
    puts
    puts ("-" * 70)
    puts
  end

  def dump_generator_attribute_names
    generator_attribute_names = [
      :table_name,
      :file_name,
      :class_name,
      :model_controller_name,
      :model_controller_class_path,
      :model_controller_file_path,
      :model_controller_class_nesting,
      :model_controller_class_nesting_depth,
      :model_controller_class_name,
      :model_controller_singular_name,
      :model_controller_plural_name,
      :model_controller_file_name,  :model_controller_singular_name,
      :model_controller_table_name, :model_controller_plural_name,
      :model_controller_routing_name,           # new_user_path
      :model_controller_routing_path,           # /users/new
      :model_controller_controller_name,        # users
      :fixtures_name,
      :model_name
    ]
    generator_attribute_names.each do |attr|
      puts "%-40s %s" % ["#{attr}:", self.send(attr)]  # instance_variable_get("@#{attr.to_s}"
    end

  end
end

# sanitize non-private use of the word 'user'
# grep user -ri .| ruby -pe \
#   '$_.gsub!(/current_user|@user|session\[:user_id\]|mock_user/, ""); $_="" unless $_ =~ /^[^:]+:.*user/'
