require File.dirname(__FILE__) + '/../test_helper'
require '<%= model_controller_file_name %>_controller'

# Re-raise errors caught by the controller.
class <%= model_controller_class_name %>Controller; def rescue_action(e) raise e end; end

class <%= model_controller_class_name %>ControllerTest < Test::Unit::TestCase

  fixtures :<%= fixtures_name %>

  def setup
    @controller = <%= model_controller_class_name %>Controller.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_signup
    assert_difference '<%= class_name %>.count' do
      create_<%= model_name %>
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= model_name %>(:login => nil)
      assert assigns(:<%= model_name %>).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= model_name %>(:password => nil)
      assert assigns(:<%= model_name %>).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= model_name %>(:password_confirmation => nil)
      assert assigns(:<%= model_name %>).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= model_name %>(:email => nil)
      assert assigns(:<%= model_name %>).errors.on(:email)
      assert_response :success
    end
  end

  protected
    def create_<%= model_name %>(options = {})
      post :create, :<%= model_name %> => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
    end
end
