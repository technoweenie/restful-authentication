require 'access_control/exceptions'
#
# Access control defines how your app enforces and responds to permissions.
#
# This is a skeleton framework for access control.  It's expected that you'll
# either add simple logic to get_authorization, or use a security component.
#
module AccessControl
protected

  #
  # Access Control
  #

  #
  # Check if the user is authorized.
  #
  # Call with positional args (assumes current_user as the subject)
  #   authorized? action, resource, *args
  # or call with options
  #   authorized? :for => user, :to => action, :on => resource, :context => any_extra_context
  #
  # Examples:
  #   authorized? :for => user, :to => :log_in_as_user # check if user is activated
  #   authorized? :destroy, @comment # can current_user destroy this comment?
  #
  # Don't put any logic in here -- use get_authorization for that.
  #
  def authorized? *args
    decision = get_authorization_with_args *args
    is_denial?(decision) ? false : decision
  end

  #
  # Demands that the user is authorized.  Acts just like authorized?, but raises
  # an exception if access is denied.
  #
  def demand_authorization! *args
    decision = get_authorization_with_args *args
    raise(decision||AccessDenied) if is_denial?(decision)
    decision
  end

  #
  # Best for use with before_filter
  #
  # Fills in request from controller action params:
  #   :for => current_user, :to => action, :on => self.class, :context => params
  #
  # If user is not authorized, raises an AccessDenied exception; see
  # handle_access_denied, below.
  #
  def authorization_filter!
    # this isn't a very good guess.  Can we do better?
    resource_guess = self.class
    decision = get_authorization_with_args :for => current_user,
      :to => params[:action],
      :on => resource_guess,
      :context => params
    raise(decision||AccessDenied) if is_denial?(decision)
    decision
  end

  #
  # Plumbing for Authorization / Policy
  #

  # normalize request then call get_authorization
  def get_authorization_with_args *args
    get_authorization parse_access_req_args(*args)
  end
  def parse_access_req_args *args
    req = args.extract_options!
    req.assert_valid_keys(:for, :to, :on, :context)
    if args
      # ordered params
      action, resource, context = args
      req.reverse_merge! :to => action, :on => resource, :context => context
    end
    # request on behalf of current user if none specified
    # (note that an explicit :for => nil or false is left untouched)
    req[:for]    = current_user unless req.include? :for
    return req
  end

  #
  # decision is a denial if
  # * false/nil
  # * it's a SecurityError type of Exception (eg AccessDenied or AuthenticationError)
  #
  def is_denial? decision
    (!decision) || (decision.is_a?(Class) && (decision <= SecurityError))
  end

  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def handle_access_denied
    respond_to do |format|
      format.html do
        store_location
        redirect_to new_session_path
      end
      # format.any doesn't work in rails version < http://dev.rubyonrails.org/changeset/8987
      # you may want to change format.any to e.g. format.any(:js, :xml)
      format.any do
        request_http_basic_authentication 'Web Password'
      end
    end
  end

  #
  # Store the URI of the current request in the browser-session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.request_uri
  end

  #
  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.  Set an appropriately modified
  #   after_filter :store_location, :only => [:index, :new, :show, :edit]
  # for any controller you want to be bounce-backable.
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  module ClassMethods
  end

  #
  # Monkeypatch into include recipient
  #
  def self.included(recipient)
    # puts "#{recipient}: including AuthorizationController"
    recipient.extend ClassMethods
    recipient.class_eval do
      # gracefully catch and redirect access denied errors.
      # override handle_access_denied if you need something fancier.
      rescue_from AccessDenied, :with => :handle_access_denied
    end
    # Make authorized? and demand_authorization! available as helper methods
    recipient.send :helper_method, :authorized?, :demand_authorization! if recipient.respond_to? :helper_method
  end
end
