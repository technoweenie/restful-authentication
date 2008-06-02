# class <%= parent_class_name %>Observer < ActiveRecord::Observer
#   def after_create(<%= parent_model_name %>)
#     <%= parent_class_name %>Mailer.deliver_signup_notification(<%= parent_model_name %>)
#   end
#
#   def after_save(<%= parent_model_name %>)
#     <%= parent_class_name %>Mailer.deliver_activation(<%= parent_model_name %>) if <%= parent_model_name %>.recently_activated?
#   end
# end
