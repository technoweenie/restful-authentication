module Authentication::ByCookieToken

  # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
  # for the paranoid: we _should_ be storing user_token = hash(cookie_token, request IP)
  def login_from_cookie
    user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
    if user && user.remember_token? && become_logged_in_as(user)
      handle_remember_cookie! false # freshen cookie token (keeping date)
      @current_user
    end
  end
  # hooks into login chain at higher priority
  def try_login_chain_with_cookie
    login_from_cookie || try_login_chain_without_cookie
  end

  def logout_chain_with_cookie
    # Kill server- and client-side auth cookie
    kill_remember_cookie!
    logout_chain_without_cookie
  end

  #
  # Remember_me Tokens
  #
  # Cookies shouldn't be allowed to persist past their freshness date,
  # and they should be changed at each login

  def valid_remember_cookie?
    return nil unless @current_user
    (@current_user.remember_token?) && (cookies[:auth_token] == @current_user.remember_token)
  end

  # Refresh the cookie auth token if it exists, create it otherwise
  def handle_remember_cookie! new_cookie_flag
    return unless @current_user
    case
    when valid_remember_cookie? then @current_user.refresh_token # keeping same expiry date
    when new_cookie_flag        then @current_user.remember_me
    else                             @current_user.forget_me
    end
    send_remember_cookie!
  end

  def kill_remember_cookie!
    # Kill server-side auth cookie.  
    @current_user.forget_me if @current_user
    # kill client-side auth cookie
    cookies.delete :auth_token
  end

  def send_remember_cookie!
    cookies[:auth_token] = {
      :value   => @current_user.remember_token,
      :expires => @current_user.remember_token_expires_at }
  end

  #
  # Plumbing
  #
  def self.included recipient
    #puts "From #{recipient} including Authentication::ByCookieToken"
    recipient.alias_method_chain(:try_login_chain,  :cookie) unless recipient.instance_methods.include?('try_login_chain_without_cookie')
    recipient.alias_method_chain(:logout_chain,     :cookie) unless recipient.instance_methods.include?('logout_chain_without_cookie')
  end
end

#
# Stuff remember_token functionality into the User model.
#
module Identity::CookieToken

  def remember_token?
    (!remember_token.blank?) &&
      remember_token_expires_at && (Time.now.utc < remember_token_expires_at.utc)
  end

  # These create and unset the fields required for remembering visitors between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = self.class.make_token
    save(false)
  end

  # refresh token (keeping same expires_at) if it exists
  def refresh_token
    if remember_token?
      self.remember_token = self.class.make_token
      save(false)
    end
  end

  #
  # Deletes the server-side record of the authentication token.  The
  # client-side (browser cookie) and server-side (this remember_token) must
  # always be deleted together.
  #
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

end
