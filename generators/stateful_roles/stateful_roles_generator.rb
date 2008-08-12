class RestfulAuthenticationExtrasGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # m.directory "lib"
      # m.template 'README', "README"
    end
  end
end
class RestfulAuthenticationExtrasGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # m.directory "lib"
      # m.template 'README', "README"


      m.directory File.join('app/views', class_path, "#{file_name}_mailer") if options[:include_activation]
      if options[:include_activation]
        %w( mailer observer ).each do |model_type|
          m.template "#{model_type}.rb", File.join('app/models',
                                               class_path,
                                               "#{file_name}_#{model_type}.rb")
        end
      end
        if options[:include_activation]
          m.template 'test/mailer_test.rb', File.join('test/unit', class_path, "#{file_name}_mailer_test.rb")
        end
      if options[:include_activation]
        # Mailer templates
        %w( activation signup_notification ).each do |action|
          m.template "#{action}.html.erb",
                     File.join('app/views', "#{file_name}_mailer", "#{action}.html.erb")
        end
      end



    #
    # Post-install notes
    #
    action = File.basename($0) # grok the action from './script/generate' or whatever
    case action
    when "generate"
      if !options[:quiet]
        puts "- Add an observer to config/environment.rb"
        puts "    config.active_record.observers = :#{file_name}_observer"
        end
        if options[:stateful]
          puts "- Install the acts_as_state_machine plugin:"
          puts "    svn export http://elitists.textdriven.com/svn/plugins/acts_as_state_machine/trunk vendor/plugins/acts_as_state_machine"
        end
        if options[:include_activation]
          puts %(    map.activate '/activate/:activation_code', :controller => '#{users_controller_file_name}', :action => 'activate', :activation_code => nil)
        end
        if options[:stateful]
          puts  "  and modify the map.resources :#{users_controller_file_name} line to include these actions:"
          puts  "    map.resources :#{users_controller_file_name}, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete }"
        end

    end
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

