class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    add_column :<%= user_model_table_name %>, :roles, :text, :default => '[:user, :active]'
    Identity::AddOrMakeAdminUser.add_or_make_admin_user
  end

  def self.down
    remove_column :users, :roles
  end

end
