module Identity::NilRoles
  #
  # This example gives every user two roles: :user and :active, and no other,
  # it satisfies the minimal 
  #
  def has_role? role
    [:user, :active].include? role
  end

  #
  # Roles are fixed
  #
  def assign_role! role
    raise "Can't assign or revoke roles: ever user is the same."
  end
  def revoke_role! role
    raise "Can't assign or revoke roles: ever user is the same."
  end
  def set_role! role, should_assign
    if should_assign
      assign_role! role
    else
      revoke_role! role
    end
  end
end
