class <%= class_name %>Mailer < Merb::MailController
  
  def signup_notification
    @<%= singular_name %> = params[:<%= singular_name %>]
    render_mail
  end
  
  def activation_notification
    @<%= singular_name %> = params[:<%= singular_name %>]
    render_mail
  end
  
end