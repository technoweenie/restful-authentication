require File.dirname(__FILE__) + '/../test_helper'
require (File.dirname(__FILE__) / '../authenticated_system_test_helper')
require (File.dirname(__FILE__) / ".." / "<%= singular_name %>_test_helper")
include <%= class_name %>TestHelper

# Re-raise errors caught by the controller.
class <%= model_controller_class_name %>; def rescue_action(e) raise e end; end

class <%= model_controller_class_name %>Test < Test::Unit::TestCase

  def setup
    <%= class_name %>.clear_database_table
    @controller = <%= model_controller_class_name %>.build(fake_request)
    @request = @controller.request
    @response = @controller.response
  end

  def test_should_allow_signup
    assert_difference '<%= class_name %>.count', 1 do
      create_<%= file_name %>
      assert_equal 302, controller.status
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:login => nil)
      assert controller.assigns(:<%= file_name %>).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:password => nil)
      assert controller.assigns(:<%= file_name %>).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:password_confirmation => nil)
      assert controller.assigns(:<%= file_name %>).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:email => nil)
      assert controller.assigns(:<%= file_name %>).errors.on(:email)
      assert_response :success
    end
  end
  <% if options[:include_activation] %>
    def test_should_activate_user
      create_<%= singular_name %>( :login => 'aaron', :password => "test", :password_confirmation => "test")
      @<%= singular_name %> = <%= class_name %>.find_with_conditions( :login => 'aaron' )
      assert_not_nil @<%= singular_name %>
      assert_nil <%= class_name %>.authenticate('aaron', 'test')
      get url(:<%= singular_name %>_activation, :activation_code => @<%= singular_name %>.activation_code )
      assert_equal '/', controller.headers['Location']
      assert_response :redirect
    end

    def test_should_not_activate_user_without_key
      create_<%= singular_name %>( :login => 'aaron', :password => "test", :password_confirmation => "test")
      @<%= singular_name %> = <%= class_name %>.find_with_conditions( :login => 'aaron' )
      assert_not_nil @<%= singular_name %>
      assert_nil <%= class_name %>.authenticate('aaron', 'test')
      assert_raise ArgumentError do
        @controller = <%= model_controller_class_name %>.build(fake_request)
        controller.dispatch(:activate)
      end
      assert_nil User.authenticate('aaron', 'test')
    end

    def test_should_not_activate_user_with_blank_key
      create_<%= singular_name %>( :login => 'aaron', :password => "test", :password_confirmation => "test")
      @<%= singular_name %> = <%= class_name %>.find_with_conditions( :login => 'aaron' )
      assert_not_nil @<%= singular_name %>
      assert_nil <%= class_name %>.authenticate('aaron', 'test')
      get url(:user_activation, :activation_code => "")
      assert_nil <%= class_name %>.authenticate('aaron', 'test')
    end<% end %>

  protected
  def create_<%= singular_name %>(options = {})
    post "/<%= model_controller_plural_name %>", :<%= singular_name %> => valid_<%= singular_name %>_hash.merge(options)
  end
end
