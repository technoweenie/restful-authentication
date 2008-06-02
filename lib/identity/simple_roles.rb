module Identity::SimpleRoles
  # Verifies that parent module is in place for us to override
  def self.included(recipient)
    recipient.serialize :roles
    raise "Because #{self.class} extends Identity, #{recipient.class.to_S} must include it before first before #{self.class}" unless recipient.included_modules.include?(Identity)
  end

  #
  # Define any user roles here -- eg :moderator or :admin.
  #
  # This example gives every user two roles: :user and :active, and no other.
  #
  # This is just a stub called by the authorization routines.  Add logic over
  # there if you want these roles to do anything.  For more complex needs, see
  # notes/RailsPlugins.txt for role-based security plugins
  #
  def has_role? role
    [:user, :active].include? role
  end

  #
  # Explicitly assign/revoke

  # Adds role. No error if user already has role.
  # returns updated user.roles
  def assign_role! role, skip_save=false
    self.roles << role
    self.roles.uniq!
    self.save(false) unless (skip_save==:skip_save)
    self.roles
  end

  # Removes role. No error if user did not have role.
  # returns updated user.roles
  def remove_role! role, skip_save=false
    self.roles.delete role
    self.save(false) unless (skip_save==:skip_save)
    self.roles
  end

  # give a role and true (to assign) and false (to revoke)
  # returns updated user.roles
  def set_role! role, should_assign, skip_save=false
    if should_assign
      assign_role! role, skip_save
    else
      remove_role! role, skip_save
    end
  end

end
