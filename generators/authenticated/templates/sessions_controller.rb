# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController

  # render new.rhtml
  def new
  end

  #
  # Log in using password
  #
  # Ensure that **no permanent resources are alloted** except in the else block.
  # (Assigning to current_user, setting a cookie, arming nukes, etc.)
  # http://www.owasp.org/index.php/Guide_to_Authentication#Positive_Authentication
  #
  def create
    logout_keeping_session!
    begin
      login_by_password! params[:login], params[:password]
    rescue Exception => error
      handle_login_error error
    else # success!
      remember_me_flag = (params[:remember_me] == "1")
      handle_remember_cookie! remember_me_flag
      flash[:notice] = "Welcome, #{current_user.login}"
      redirect_back_or_default('/')
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected

  def try_again
    @login       = params[:login]
    @remember_me = params[:remember_me]
    render :action => 'new'
  end

  # Track failed login attempts
  def log_failed_signin error
    flash[:error] = "#{error} with login '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}: #{error}"
  end

  # react to login failures
  def handle_login_error error
    logout_keeping_session!
    begin
      raise error
    rescue AccountNotActive => error
      log_failed_signin error
      redirect_back_or_default('/')
    rescue AccountNotFound, BadPassword => error
      log_failed_signin error
      try_again
    rescue AuthenticationError, SecurityError => error
      log_failed_signin error
      redirect_back_or_default('/')
    end
    # general exceptions are uncaught
  end

end
