
  # Returns true if the user has just been activated.
  def pending?
    @activated
  end

  def has_role?(name)
    self.roles.find_by_name(name) ? true : false
  end
