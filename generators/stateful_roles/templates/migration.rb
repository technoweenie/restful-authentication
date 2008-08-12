class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    add_column :<%= user_class %>, :state,                     :string, :null => :no, :default => 'passive'
    add_column :<%= user_class %>, :deleted_at,                :datetime
    say_with_time "Activating existing users..." do
      <%= user_class %>.find(:all).each do |u|
        u.activate!
      end
    end
  end

  def self.down
    remove_column :<%= user_class %>, :state
    remove_column :<%= user_class %>, :deleted_at
  end
end
