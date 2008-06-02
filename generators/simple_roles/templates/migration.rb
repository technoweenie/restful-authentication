class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    add_column :<%= parent_table_name %>, :roles, :text, :default => '<%= default_roles_list.to_json %>'
    say_with_time "Assigning :admin role to a new or existing admin user..." do
      Identity::AddOrMakeAdminUser.add_or_make_admin_user
    end
  end

  def self.down
    remove_column :users, :roles
  end

end
