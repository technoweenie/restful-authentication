module AccessControl::ApproveAllUsers

  #
  # only active users can log in;
  # everything else is approved for users
  #
  def get_authorization req
    user, action = req.values_at(:for, :to)
    case
    when action == :login
      if user && user.active? then return :allow
      else return AccountNotActive end
    else
      # approved for user, denied for nil/false (logged out)
      user
    end
  end

end
