class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= table_name %>", :force => true do |t|
      # Identity
      t.string   :login,                     :limit => 40
      t.string   :name,                      :limit => 100, :default => '', :null => true
      t.string   :email,                     :limit => 100
      t.timestamps
      # for Authentication::ByPassword
      t.string   :crypted_password,          :limit => 40
      t.string   :salt,                      :limit => 40
      # for Authentication::ByCookieToken
      t.string   :remember_token,            :limit => 40
      t.datetime :remember_token_expires_at
    end
    add_index :<%= table_name %>, :login, :unique => true
  end

  def self.down
    drop_table "<%= table_name %>"
  end
end
