# If your security policy is very simple, edit get_authorization below.
#
# Or, use an authorization plugin like those in notes/RailsPlugins.txt
# and use get_authorization to route to it
#
module SecurityPolicy
  #
  # get_authorization(req)
  #   Decides if a request should be allowed or denied
  #
  # req is a hash taking
  # * :for => the subject making the request.
  #    Use req[:for], not current_user, to make your decision
  # * :to => the requested action
  # * :on => the resource or resources request will act on
  # * :extra => any extra information passed by the access control request
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
  def get_authorization req
    <%= model_name %> = req[:for]
    <%= model_name %>.is_a?(<%= class_name %>)
  end
end
