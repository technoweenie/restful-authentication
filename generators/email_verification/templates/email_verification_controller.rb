UsersController.class_eval do
  #
  # verifies the user's email address belongs to that user
  #
  # By default, we automatically log visitor in on email verification.  This is
  # convenient, but less secure and assumes user is now authorized to log in.
  #
  # To change this, replace the lines including and following become_logged_in_as! with:
  #   flash[:notice] = "Email verified! Please sign in to continue."
  #   redirect_to '/login'
  #
  def verify_email
    logout_keeping_session!
    begin
      user = User.find_and_verify_email!(params[:email_verification_code]) or raise AuthenticationError
      become_logged_in_as! user
      flash[:notice] = "Email verified! Welcome, #{user.login}."
      redirect_back_or_default('/')
    rescue EmailVerificationCodeMissing, EmailVerificationCodeNotFound => error
      handle_email_verification_error error
    rescue AuthenticationError => error
      # shouldn't happen, so be discrete
      handle_email_verification_error error, 'Error confirming your email. Contact an admin if problems persist.'
    end
  end

protected

  def handle_email_verification_error error, msg=nil
    msg ||= error.to_s
    flash[:error] = msg
    logger.warn "Failed email verification for code='#{params[:email_verification_code]}' from #{request.remote_ip} at #{Time.now.utc}: #{error}"
    redirect_back_or_default('/')
  end
end
