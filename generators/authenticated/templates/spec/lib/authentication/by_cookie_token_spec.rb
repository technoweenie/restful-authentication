require File.dirname(__FILE__) + '/../../spec_helper'

describe Authentication do
  before(:each) do
    @<%= model_name %> = mock_<%= model_name %>
    @mock_controller, @mock_controller_class = mock_authentication_controller
    @mock_controller_class.send(:include, Authentication::ByCookieToken)
    @mock_controller.stub!(:cookies).and_return( {} )
    stub_auth!(@mock_controller, true) # <%= model_name %> is authorized for anything; call stub_auth! again to override.
  end

  # Shared
  describe "it refreshes token", :shared => true do
    it "refreshes visitor's token"        do  @user.should_receive(:refresh_token).at_least(:once) end
    it "does not create visitor's token"  do  @user.should_not_receive(:remember_me) end
    it "does not kill visitor's token"    do  @user.should_not_receive(:forget_me) end
    it "sends the token"                  do  @mock_controller.should_receive(:send_remember_cookie!).at_least(:once) end
  end
  describe "it creates token", :shared => true do
    it "does not refresh visitor's token" do  @user.should_not_receive(:refresh_token)end
    it "creates new visitor's token"      do  @user.should_receive(:remember_me) end
    it "does not kill visitor's token"    do  @user.should_not_receive(:forget_me)  end
    it "sends the token"                  do  @mock_controller.should_receive(:send_remember_cookie!).at_least(:once) end
  end
  describe "it destroys token", :shared => true do
    it "does not refresh visitor's token" do  @user.should_not_receive(:refresh_token)end
    it "does not create visitor's token"  do  @user.should_not_receive(:remember_me) end
    it "kills visitor's token"            do  @user.should_receive(:forget_me).at_least(:once)  end
    it "sends the token"                  do  @mock_controller.should_receive(:send_remember_cookie!).at_least(:once) end
  end

  #
  # Cookie Login
  #
  describe "Logging in by cookie" do
    before do
      <%= class_name %>.stub!(:find_by_remember_token).with('valid_token').and_return(@user)
      set_remember_token 'valid_token', 5.minutes.from_now.utc # this needs to match config.active_record.default_timezone (utc or not)
    end
    def set_remember_token token, time
      @user.stub!(:remember_token).and_return( token )
      @user.stub!(:remember_token_expires_at).and_return( time )
      @user.stub!(:refresh_token)
    end
    def set_remember_cookie(cookie)
      @mock_controller.stub!(:cookies).and_return({ :auth_token => cookie })
    end

    describe "when successful" do
      before(:each) do
        set_remember_cookie 'valid_token'
        @user.stub!(:remember_token?).and_return(true)
      end
      it_should_behave_like "it refreshes token"
      it 'tries session login first'   do
        @mock_controller.should_receive(:try_login_from_session).and_return(@user)
        @mock_controller.should_not_receive(:login_from_cookie)
      end
      it "gets to cookie login if login by session doesn't work" do
        @mock_controller.should_receive(:try_login_from_session).and_return(nil)
        @mock_controller.should_receive(:login_from_cookie ).and_return(@user)
      end
      it "checks visitor's token"   do  @user.should_receive(:remember_token?).at_least(:once).and_return(true) end
      it "checks cookie token"      do  @mock_controller.should_receive(:handle_remember_cookie!).with(false) end
      it "checks for authorization" do
        @mock_controller.should_receive(:get_authorization).at_least(:once).with({:for => @user, :to => :login, :on => nil, :context => nil}).and_return(true)
      end
      after(:each) do
        @mock_controller.send(:current_user).should == @user
      end
    end
    describe "when not authorized to log in" do
      before(:each) do
        set_remember_cookie 'valid_token'
        @user.stub!(:remember_token?).and_return(true)
      end
      it "fails quietly on no authorization" do
        stub_auth!(@mock_controller, false)
        @mock_controller.send(:current_user).should == false
      end
    end

    it 'fails cookie login with bad cookie' do
      @mock_controller.should_receive(:cookies).at_least(:once).and_return({ :auth_token => 'i_haxxor_joo' })
      @user.should_not_receive(:handle_remember_cookie!)
      @mock_controller.send(:current_user).should be_false
    end

    it 'fails cookie login with no cookie' do
      set_remember_token nil, nil
      @mock_controller.should_receive(:cookies).at_least(:once).and_return({ })
      @user.should_not_receive(:handle_remember_cookie!)
      @mock_controller.send(:current_user).should be_false
    end

    it 'fails expired cookie login' do
      set_remember_token 'valid_token', 5.minutes.ago
      @mock_controller.should_receive(:cookies).at_least(:once).and_return({ :auth_token => 'valid_token' })
      @user.should_receive(:remember_token?).at_least(:once).and_return(false)
      @user.should_not_receive(:handle_remember_cookie!)
      @mock_controller.send(:current_user).should be_false
    end
  end

  #
  # Cookie & Token handling from external login
  #
  cookie_outcomes = [
    [:valid, :want_new, :should_refresh],
    [:valid, false,     :should_refresh],
    [false,  :want_new, :should_create],
    [false,  false,     :should_destroy],
  ]
  cookie_outcomes.each do |has_valid, wants_new, expected_action|
    describe "handling cookie on login" do
      before(:each) do
        @mock_controller.send(:current_user=, @user)
        @mock_controller.should_receive(:valid_remember_cookie?).at_least(:once).and_return(has_valid)
        @user.stub!(:refresh_token)
        @user.stub!(:remember_me)
        @user.stub!(:forget_me)
        @mock_controller.stub!(:send_remember_cookie!)
      end
      case expected_action
      when :should_refresh then it_should_behave_like "it refreshes token"
      when :should_create  then it_should_behave_like "it creates token"
      when :should_destroy then it_should_behave_like "it destroys token"
      else raise 'hell'
      end
      after(:each) do @mock_controller.send(:handle_remember_cookie!, wants_new) end
    end
  end

  #
  # Logout
  #
  describe "logout cookie handling" do
    before do
      @mock_controller_class.send(:public, :logout_keeping_session!, :current_user, :current_user=)
    end
    it 'kills my auth_token cookie' do
      @mock_controller.should_receive(:kill_remember_cookie!);
      @mock_controller.logout_keeping_session!
    end
    it 'forgets me when logged in'   do
      @mock_controller.stub!(:try_login_from_session)
      @mock_controller.send(:current_user=, @user)
      @user.should_receive(:forget_me);
      @mock_controller.logout_keeping_session!
    end
    it "doesn't forgets when logged out" do
      @mock_controller.current_user = nil;   @user.should_not_receive(:forget_me);
      @mock_controller.logout_keeping_session!
    end
  end

end
