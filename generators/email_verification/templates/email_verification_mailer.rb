# -*- coding: mule-utf-8 -*-
class <%= parent_class_name %>::EmailVerificationMailer < ActionMailer::Base
  def signup_notification(<%= parent_model_name %>)
    setup_email(<%= parent_model_name %>)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://YOURSITE/activate/#{<%= parent_model_name %>.activation_code}"
  end

  def activation(<%= parent_model_name %>)
    setup_email(<%= parent_model_name %>)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://YOURSITE/"
  end

  protected
    def setup_email(<%= parent_model_name %>)
      @recipients  = "#{<%= parent_model_name %>.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[YOURSITE] "
      @sent_on     = Time.now
      @body[:<%= parent_model_name %>] = <%= parent_model_name %>
    end
end

