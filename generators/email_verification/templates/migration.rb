class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    #add_column :<%= parent_table_name %>, :email_verification_code, :string, :limit => 40
    #add_column :<%= parent_table_name %>, :email_verified_at,       :datetime
    say_with_time "Marking existing users' emails as verified..." do
      <%= parent_class_name %>.send(:include, Trustification::EmailVerification)
      <%= parent_class_name %>.find(:all).each do |u|
        u.send :verify_email!
      end
    end
  end

  def self.down
    remove_column :<%= parent_table_name %>, :email_verification_code
    remove_column :<%= parent_table_name %>, :email_verified_at
  end
end
