class <%= class_name %>Observer < ActiveRecord::Observer
  def after_create(<%= file_name %>)
    <%= class_name %>Notifier.deliver_signup_notification(<%= file_name %>)
  end

  def after_save(<%= file_name %>)
    <%= class_name %>Notifier.deliver_activation(<%= file_name %>) if <%= file_name %>.recently_activated?
  end
end