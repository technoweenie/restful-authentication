# If your security policy is very simple, edit get_authorization below.
#
# Or, use an authorization plugin like those in notes/RailsPlugins.txt
# and use get_authorization to route to it
#
module SecurityPolicy
protected
  #
  # get_authorization(req)
  #   Decides if a request should be allowed or denied
  #
  # req is a hash taking
  # * :for => the subject making the request.
  #    Use req[:for], not current_user, to make your decision
  # * :to => the requested action
  # * :on => the resource or resources request will act on
  # * :context => any extra information passed by the access control request
  #
  # get_authorization can return
  # * nil/false will raise AccessDenied (demands) or deny access (requests)
  # * any exception derived from SecurityError will raise that exception (demands)
  #   or deny access (requests)
  # * any true value grants access, and becomes the return value of the
  #   access request
  #
  # Examples:
  #   # allow any <%= model_name %> unless it's that guy bob. bob's a jerk.
  #   def get_authorization req
  #     req[:for].is_a(<%= class_name %>) && (req[:for].login != "bob")
  #   end
  #
  #   # only active <%= model_name.pluralize %> can do things.
  #   def get_authorization req
  #     <%= model_name %> = req[:for]
  #     <%= model_name %>.is_a?(<%= class_name %>) && <%= model_name %>.has_role?(:active)
  #   end
  #
  def get_authorization req
    <%= model_name %> = req[:for]
    <%= model_name %>.is_a?(<%= class_name %>)
  end
end

User.class_eval do
protected
  #
  # Most roles/privileges are assigned explicitly: designating a user to be a
  # moderator, granting 'push' permissions to a newly-hired programmer.
  #
  # Some are granted and revoked automatically, though.  Many sites don't make a
  # user active until they've verified their email address.  A communal blog
  # might not allow 'front-page posting' for the first month after joining.
  #
  # reconcile_privileges! lets the Policy module assign or revoke privileges
  # based on the subject's current state.
  #
  # In order to allow it as a :before_save filter,
  # reconcile_privileges! **DOES NOT** save the model.
  # You have to do this yourself.
  #
  def reconcile_privileges! occasion=nil, *more_info
    logger.info "Reassigning privileges for #{self.class} id #{self.id}: #{occasion} #{more_info.to_json}" if occasion
    # :active if and only if email is verified.
    set_role! :active,  email_verified?, :skip_save
    # :veteran if older than 1 month
    # set_role! :veteran, ( (Time.now - self.created_at) >= 1.months ), :skip_save
  end

  # It's safe to set reconcile_privileges! as a before_save filter,
  # or else be sure to call it explicitly after potential trust changes
  # before_save :reconcile_privileges!
end
