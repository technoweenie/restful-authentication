class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= table_name %>", :force => true do |t|
      t.string   :login,                     :limit => 40
      t.string   :name,                      :limit => 100, :default => '', :null => true
      t.string   :email,                     :limit => 100
      t.string   :crypted_password,          :limit => 40
      t.string   :salt,                      :limit => 40
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :remember_token,            :limit => 40
      t.datetime :remember_token_expires_at
<% if options[:include_activation] -%>
      t.string   :activation_code,           :limit => 40
      t.datetime :activated_at<% end %>
<% if options[:stateful] -%>
      t.string   :state,                     :null => :no, :default => 'passive'
      t.datetime :deleted_at<% end %>
    end
    add_index :<%= table_name %>, :login, :unique => true
  end

  def self.down
    drop_table "<%= table_name %>"
  end
end
