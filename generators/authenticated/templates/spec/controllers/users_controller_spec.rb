require File.dirname(__FILE__) + '<%= ('/..'*model_controller_class_nesting_depth) + '/../spec_helper' %>'

describe <%= model_controller_class_name %>Controller do
  before(:each) do
    @user = mock_user new_user_params
    @user.stub!(:new_record?).and_return(false)
    <%= class_name %>.stub!(:new).and_return(@user)
  end

  #
  # Begin login
  #
  describe "login page" do
    def do_signup_page() get :new end
    it "shows me the login page"    do do_signup_page; response.should render_template("new") end
    it "constructs a new user"      do <%= class_name %>.should_receive(:new).with().and_return(@user); do_signup_page; end
    it "assigns new user for page"  do do_signup_page; assigns[:user].should equal(@user);  end
  end

  #
  # Signup
  #
  describe "signing up" do
    def default_signup_options
      { 'login' => 'quire', 'email' => 'quire@example.com',
        'password' => 'quire69', 'password_confirmation' => 'quire69' }
    end
    def do_signup(options = {})
      post :create, :user => default_signup_options.merge(options)
    end
    describe "successfully" do
      before(:each) do
        @user.stub!(:save).and_return(@user)
        controller.stub!(:authorized?).with({:for => @user, :to => :login}).and_return(true)
      end
      it "ensures I'm logged out"                do controller.should_receive(:logout_keeping_session!); do_signup end
      it "constructs a new user"                 do <%= class_name %>.should_receive(:new).with(default_signup_options).and_return(@user); do_signup; end
      it "saves the new user"                    do @user.should_receive(:save).with().and_return(@user);  do_signup;  end
      it 'redirects to the home page'            do do_signup; response.should redirect_to('/')   end
      it "welcomes me nicely"                    do do_signup; response.flash[:notice].should =~ /Thank.*sign.*up/i   end
      # auto login if authorized to do so
      it "checks if I can log in"                do controller.should_receive(:authorized?).with({:for => @user, :to => :login}).and_return(true);  do_signup;   end
      it "checks if I can log in"                do controller.should_receive(:demand_authorization!).with({:for => @user, :to => :login}).and_return(true);  do_signup;   end
      it "logs me in "                           do controller.should_receive(:become_logged_in_as!).and_return(true);  do_signup;   end
      # fail gracefully or correctly on can't auto-login
      it "doesn't auto-login if not authorized" do controller.should_receive(:authorized?).and_return(false);        controller.should_not_receive(:become_logged_in_as!); do_signup; end
      it "catches can't-auto-log-in error"       do controller.stub!(:become_logged_in_as!).and_raise(SecurityError); lambda{ do_signup }.should_not raise_error end
      it "kills privileges on login error"       do controller.stub!(:become_logged_in_as!).and_raise(SecurityError); controller.should_receive(:logout_keeping_session!).twice; do_signup; end
      it "doesn't catch other errors"            do controller.stub!(:become_logged_in_as!).and_raise("frobnozz");    lambda{ do_signup }.should     raise_error("frobnozz") end
    end

    #
    # Failed signup
    #
    describe "Failed signup" do
      before do
        @user.stub!(:save).and_return(false)
        [:password=, :password_confirmation=].each{ |m| @user.stub!(m) }
      end
      it 're-renders the signup page'          do do_signup; response.should render_template(:new); response.should_not be_redirect end
      it "notifies me of the error"            do do_signup; response.flash[:error].should =~ /couldn't.*sorry.*try again.*contact/i   end
      it "repopulates what I entered"          do do_signup; assigns[:user].should == @user end
      it "clears the password & confirmation"  do @user.should_receive(:password=).with(''); @user.should_receive(:password_confirmation=).with(''); do_signup; end
    end

  end
end
