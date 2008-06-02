require 'authentication/exceptions'
module Authentication
protected

  # Returns true or false if the user is logged in.
  # Preloads @current_user with the user model if they're logged in.
  def logged_in?
    !!current_user    # !!bang bang -- only true or false
  end

  # Accesses the current user from the browser-session.
  # Future calls avoid the database because nil is not equal to false.
  def current_user
    return false if (@current_user == false)
    @current_user ||= (try_login_from_session || try_login_chain || false)
  end

  # Store the given user id in the browser-session.
  # for no user, sets the current_user == false sentinel ("not logged in, and don't try")
  def current_user=(new_user)
    session[:user_id] = new_user ? new_user.id : nil
    @current_user     = new_user || false
  end

  #
  # If you go from a logged-out state to a logged-in state (basically, all
  # logins except by session variable), it should pass through here.
  #
  # become_logged_in_as! will raise an exception if the user cannot log in.
  # if it returns, the user has successfully logged in.
  #
  # Ensure you "Fail Closed" -- that **you allot no privileged resources**
  # (assign to current_user, set a cookie, arm nukes, etc.) until this succeeds.
  # Either wait until success to allot resources (best) or else rescue the
  # exception, roll back changes, then re-raise or handle the exception.
  #
  # http://www.owasp.org/index.php/Guide_to_Authentication#Positive_Authentication
  #
  def become_logged_in_as! user
    # Protects against browser-session fixation attacks, causes request
    # forgery protection if visitor resubmits an earlier form using back
    # button. Uncomment if you understand the tradeoffs.
    # reset_session
    raise AuthenticationError unless user
    demand_authorization! :for => user, :to => :login
    self.current_user = user
  end

  #
  # try to log in as the user.
  # if they're not authorized, don't do anything (and return false)
  # if they are authorized, return user: successfully logged in
  #
  def become_logged_in_as user
    raise AuthenticationError unless user
    if authorized? :for => user, :to => :login
      self.current_user = user
    else
      self.current_user = false
    end
  end

  #
  # Login
  #

  # hook in to this by mixin this into your class:
  #   alias_method_chain :try_login_chain,  :your_passive_login_method
  def try_login_chain
  end

  # Called from #current_user.  First attempt to login by the user id stored in the browser-session.
  # does NOT call become_logged_in_as
  def try_login_from_session
    self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
  end

  #
  # Logout
  #

  # Hook in to logout_chain with alias_method_chain to perform pre-logout
  # cleanup.  Bad things will happen if you call current_user (as method;
  # @current_user is OK) or its friends (logged_in?, etc.)
  def logout_chain
  end

  # This is ususally what you want to neutralize permissions while preserving
  # session.
  #
  # Resetting the browser-session willy-nilly wreaks havoc with forgery
  # protection, and is only strictly necessary on login.  However, **all
  # browser-session state variables should be unset here**.
  def logout_keeping_session!
    # We need to retrieve the session login if any so that any server-side
    # variables -- the cookie remember_token, for instance -- can be cleared
    try_login_from_session
    logout_chain
    session[:user_id] = nil   # keeps the browser-session but kill our variable
    @current_user = false     # not logged in, and don't do it for me
  end

  # If you reset the browser-session, make sure you use redirect_to and not
  # render back to the original form; otherwise the request forgery protection
  # fails on re-submit. Browser-session reset is only really necessary when
  # you elevate privileges (eg, logged-out to logged-in).
  def logout_killing_session!
    logout_keeping_session!
    reset_session
  end

  #
  # Plumbing
  #

  def self.included(recipient)
    # Make #current_user and #logged_in? available as ActionView helper methods.
    recipient.send :helper_method, :current_user, :logged_in? if recipient.respond_to? :helper_method
  end
end
