require File.dirname(__FILE__) + '/../../spec_helper'

describe Authentication do
  before(:each) do
    @user = mock_<%= model_name %>
    @mock_controller, @mock_controller_class = mock_authentication_controller
    @mock_controller_class.send(:include, Authentication::ByPassword)
  end

  #
  # Basic Auth Login
  #
  describe "Logging in from HTTP basic auth" do
    before(:each) do
      @mock_controller.stub!(:authenticate_with_http_basic).and_yield('chunky', 'bacon')
      <%= class_name %>.stub!(:authenticate_by_password).with('chunky', 'bacon').and_return(@user)
      stub_auth!(@mock_controller, true)
    end
    it "finds us in the try_login_chain" do
      @mock_controller.should_receive(:login_from_basic_auth).and_return(@user)
      @mock_controller.send(:current_user).should == @user
    end
    it "passes to authenticate_with_http_basic" do
      @mock_controller.should_receive(:authenticate_with_http_basic).and_yield('chunky', 'bacon')
      <%= class_name %>.should_receive(:authenticate_by_password).with('chunky', 'bacon').and_return(@user)
      @mock_controller.send(:login_from_basic_auth).should == @user
    end
    it "becomes logged in the right way" do
      @mock_controller.should_receive(:become_logged_in_as!).with(@user).and_return(@user)
      @mock_controller.send(:current_user).should == @user
    end
    it "passes through any errors" do
      stub_auth!(@mock_controller, false)
      lambda{ @mock_controller.send(:current_user) }.should raise_error(AccessDenied)
    end
  end

end
