module Identity::AddOrMakeAdminUser

  def self.add_or_make_admin_user
    puts "*"*70
    admin = self.find_admin || self.make_admin
    admin.assign_role! :admin
    admin.reconcile_privileges!
    puts "  added 'admin' role"
    puts "*"*70
    admin
  end

  def self.find_admin
    admin = User.find_by_login('admin') or return false
    puts "  On preexisting admin:"
    admin
  end

  def self.make_admin
    passwd = make_random_password
    admin_params = {
      :login=>'admin',
      :email => 'admin@this-site.com',
      :password => passwd, :password_confirmation => passwd }
    admin = User.create!(admin_params)
    puts "  On newly created admin with password #{passwd}:"
    admin
  end

  def self.make_random_password
    User.make_token[1..8]
  end

end
