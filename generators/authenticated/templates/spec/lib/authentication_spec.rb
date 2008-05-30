require File.dirname(__FILE__) + '/../spec_helper'

describe Authentication do
  before(:each) do
    @<%= model_name %> = mock_user
    @mock_controller, @mock_controller_class = mock_authentication_controller
  end

  #
  # Current user
  #
  describe "logged_in?" do
    before do @mock_controller_class.send(:public, :logged_in?, :current_user=) end
    it 'is true  for current_user set'   do @mock_controller.current_user = @<%= model_name %>; @mock_controller.logged_in?.should be_true  end
    it 'is false for current_user false' do @mock_controller.current_user = false; @mock_controller.logged_in?.should be_false end
    it 'is false for current_user nil'   do @mock_controller.current_user = nil;   @mock_controller.logged_in?.should be_false end
  end
  describe "current_user accessor" do
    before do @mock_controller_class.send(:public, :current_user, :current_user=) end
    it 'does nothing when @current_user is false' do
      @mock_controller.current_user = false;
      @mock_controller.should_not_receive(:try_login_from_session)
      @mock_controller.should_not_receive(:try_login_chain)
      @mock_controller.send(:current_user).should be_false
    end
    it "returns @current_user when it's set" do
      @mock_controller.current_user = @<%= model_name %>;
      @mock_controller.should_not_receive(:try_login_from_session)
      @mock_controller.should_not_receive(:try_login_chain)
      @mock_controller.send(:current_user).should == @<%= model_name %>
    end
    it "tries to log in when @current_user is nil" do
      @mock_controller.should_receive(:try_login_from_session).and_return(nil)
      @mock_controller.should_receive(:try_login_chain).and_return(nil)
      @mock_controller.current_user.should be_false
    end
  end

  #
  # Session Login
  #
  describe "Logging in from session" do
    before do @mock_controller_class.send(:public, :try_login_from_session) end
    it "Finds user if session user_id is set" do
      @mock_controller.session[:user_id] = 'fake_user_id'
      <%= class_name %>.should_receive(:find_by_id).with('fake_user_id').and_return(@<%= model_name %>)
      @mock_controller.should_receive(:current_user=).with(@<%= model_name %>)
      @mock_controller.try_login_from_session.should == @<%= model_name %>
    end
    it "Does nothing if no session user_id" do
      @mock_controller.session[:user_id] = nil
      User.should_not_receive(:find_by_id)
      @mock_controller.should_not_receive(:current_user=)
      @mock_controller.try_login_from_session.should be_nil
    end
  end

  #
  # Logout
  #
  describe "logout_keeping_session!" do
    before do @mock_controller_class.send(:public, :logout_keeping_session!, :current_user, :current_user=) end
    it 'chains w/ other logout fns' do @mock_controller.should_receive(:logout_chain);          @mock_controller.logout_keeping_session! end
    it 'does not reset the session' do @mock_controller.should_not_receive(:reset_session);     @mock_controller.logout_keeping_session! end
    it 'nils the current user'      do @mock_controller.logout_keeping_session!;                @mock_controller.current_user.should be_false end
    it 'kills :user_id from the browser-session' do
      @mock_controller.session.should_receive(:[]=).with(:user_id, nil).at_least(:once)
      @mock_controller.logout_keeping_session!
    end
  end
  describe "logout_killing_session!" do
    before do @mock_controller_class.send(:public, :logout_killing_session!) end
    it 'first logs out keeping session' do @mock_controller.should_receive(:logout_keeping_session!); @mock_controller.logout_killing_session! end
    it 'resets the session'             do @mock_controller.should_receive(:reset_session);           @mock_controller.logout_killing_session! end
  end

  #
  # Exceptions
  #
  describe "exceptions exist with correct type" do
    it "AuthenticationError" do AuthenticationError.should < SecurityError       end
    it "AccountNotFound"     do AccountNotFound.should     < AuthenticationError end
    it "BadPassword"         do BadPassword.should         < AuthenticationError end
  end

end
