class AuthenticatedMailerGenerator < Rails::Generator::NamedBase
  
  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    rec_session = record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Notifier", "#{class_name}NotifierTest", "#{class_name}Observer"

      # Controller, helper, views, and test directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('app/views', class_path, "#{file_name}_notifier")
      m.directory File.join('test/unit', class_path)

      %w( notifier observer ).each do |model_type|
        m.template "#{model_type}.rb", File.join('app/models',
                                             class_path,
                                             "#{file_name}_#{model_type}.rb")
      end
      
      m.template 'notifier_test.rb', File.join('test/unit', class_path, "#{file_name}_notifier_test.rb")

      # Mailer templates
      %w( activation signup_notification ).each do |action|
        m.template "#{action}.rhtml",
                   File.join('app/views', "#{file_name}_notifier", "#{action}.rhtml")
      end
    end

    action = nil
    action = $0.split("/")[1]
    case action
      when "generate" 
        puts
        puts ("-" * 70)
        puts "Don't forget to add an observer to environment.rb"
        puts
        puts "  config.active_record.observers = :#{file_name}_observer"
        puts
        puts ("-" * 70)
        puts
      when "destroy" 
        puts
        puts ("-" * 70)
        puts
        puts "Thanks for using restful_authentication"
        puts
        puts "Don't forget to comment out the observer line in environment.rb"
        puts "  # config.active_record.observers = :#{file_name}_observer"
        puts
        puts ("-" * 70)
        puts
      else
        puts
    end

    rec_session
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} authenticated_mailer AuthenticatedMailerName [options]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--include-activation", 
        "Generate signup 'activation code' confirmation via email") { |v| options[:include_activation] = v }
    end
end
