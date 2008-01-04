require File.dirname(__FILE__) + '/../test_helper'
require (File.dirname(__FILE__) / '../authenticated_system_test_helper')
require (File.dirname(__FILE__) / ".." / "<%= singular_name %>_test_helper")
include <%= class_name %>TestHelper

class <%= class_name %>Test < Test::Unit::TestCase
  # # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # # Then, you can remove it from this and the functional test.
  # include AuthenticatedTestHelper
  # fixtures :<%= plural_name %>
  def setup
    <%= class_name %>.clear_database_table
    @<%= singular_name %>_1 = <%= class_name %>.new(valid_<%= singular_name %>_hash.with(
                  :login                  => 'quentin',
                  :email                  => 'quentin@example.com',
                  :password               => 'test',
                  :password_confirmation  => 'test',
                  :created_at             => Time.now - (5 * Merb::Const::DAY)
                ))
    @<%= singular_name %>_2 = User.new(valid_user_hash.with(
                  :login              => 'aaron',
                  :email              => 'aaron@example.com',
                  :password               => 'test',
                  :password_confirmation  => 'test',
                  :created_at         => Time.now - (1 * Merb::Const::DAY)
                ))   
    @<%= singular_name %>_1.save  
    @<%= singular_name %>_2.save
    
    @<%= singular_name %>_1.created_at = Time.now - (5 * Merb::Const::DAY)
    @<%= singular_name %>_2.created_at = Time.now - (1 * Merb::Const::DAY)
    
<% if options[:include_activation] -%>
    @<%= singular_name %>_1.activate
    @<%= singular_name %>_2.activate
<% end -%>
    # Reload from the db to get the right object
    @<%= singular_name %>_1 = <%= class_name %>.find_with_conditions(:login => 'quentin')
    @<%= singular_name %>_2 = <%= class_name %>.find_with_conditions(:login => 'aaron')
    
  end
    
  def test_should_create_<%= singular_name %>
    assert_difference '<%= class_name %>.count' do
      <%= singular_name %> = create_<%= singular_name %>
      assert !<%= singular_name %>.new_record?, "#{<%= singular_name %>.errors.to_yaml}"
    end
  end

  def test_should_require_login
    assert_no_difference '<%= class_name %>.count' do
      u = create_<%= singular_name %>(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference '<%= class_name %>.count' do
      u = create_<%= singular_name %>(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference '<%= class_name %>.count' do
      u = create_<%= singular_name %>(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference '<%= class_name %>.count' do
      u = create_<%= singular_name %>(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    @<%= singular_name %>_1.password = 'new password'
    @<%= singular_name %>_1.password_confirmation = 'new password'
    @<%= singular_name %>_1.save
    @<%= singular_name %>_1 = <%= class_name %>.find_with_conditions(:login => @<%= singular_name %>_1.login)
    assert_equal @<%= singular_name %>_1, <%= class_name %>.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    @<%= singular_name %>_1.login = 'quentin2'
    @<%= singular_name %>_1.save
    @<%= singular_name %>_1 = <%= class_name %>.find_with_conditions(:login => 'quentin2')
    assert_equal @<%= singular_name %>_1, <%= class_name %>.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_<%= singular_name %>
    assert_equal @<%= singular_name %>_1, <%= class_name %>.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    @<%= singular_name %>_1.remember_me
    assert_not_nil @<%= singular_name %>_1.remember_token
    assert_not_nil @<%= singular_name %>_1.remember_token_expires_at
  end

  def test_should_unset_remember_token
    @<%= singular_name %>_1.remember_me
    assert_not_nil @<%= singular_name %>_1.remember_token
    @<%= singular_name %>_1.forget_me
    assert_nil @<%= singular_name %>_1.remember_token
  end

  def test_should_remember_me_for_one_week
    before = (Time.now + 1 * Merb::Const::WEEK).utc
    @<%= singular_name %>_1.remember_me_for Merb::Const::WEEK
    after = (Time.now + 1 * Merb::Const::WEEK).utc
    assert_not_nil @<%= singular_name %>_1.remember_token
    assert_not_nil @<%= singular_name %>_1.remember_token_expires_at
    assert @<%= singular_name %>_1.remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = (Time.now + 1 * Merb::Const::WEEK).utc
    @<%= singular_name %>_1.remember_me_until time
    assert_not_nil @<%= singular_name %>_1.remember_token
    assert_not_nil @<%= singular_name %>_1.remember_token_expires_at
    assert_equal @<%= singular_name %>_1.remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = (Time.now + 2 * Merb::Const::WEEK).utc
    @<%= singular_name %>_1.remember_me
    after = (Time.now + 2 * Merb::Const::WEEK).utc
    assert_not_nil @<%= singular_name %>_1.remember_token
    assert_not_nil @<%= singular_name %>_1.remember_token_expires_at
    assert @<%= singular_name %>_1.remember_token_expires_at.between?(before, after)
  end

protected
  def create_<%= singular_name %>(options = {})
    u = <%= class_name %>.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    u.save
    u    
  end
end
