require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  before(:each) do
    @user  = mock_<%= model_name %> new_<%= model_name %>_params
  end

  #
  # Begin login
  #
  describe "login page" do
    def do_login_page() get :new end
    it "shows me the login page" do do_login_page; response.should render_template("new") end
  end

  #
  # Login
  #
  describe "Logging in" do
    #
    # Shared Methods (login)
    #
    def do_login options={}
      post :create, { :login => 'test_login', :password => 'monkey' }.merge(options)
    end

    describe "successful login", :shared => true do
      it "kills existing login"        do controller.should_receive(:logout_keeping_session!); do_login; end
      it "does not reset my session"   do controller.should_not_receive(:reset_session).and_return nil; do_login end # change if you uncomment the reset_session path
      it "greets me nicely"            do do_login; response.flash[:notice].should =~ /welcome/i   end
      it 'redirects to the home page'  do do_login; response.should redirect_to('/')   end
      it "checks authorization"        do controller.should_receive(:demand_authorization!).with({:for=>@user,:to=>:login}).and_return(true); do_login end
      it "logs me in"                  do do_login; controller.should     be_logged_in  end
    end

    describe "failed login", :shared => true do
      it 'logs out keeping session'    do controller.should_receive(:logout_keeping_session!).at_least(:once); do_login end
      it "does not reset my session"   do controller.should_not_receive(:reset_session); do_login end # session should not be reset here, even if you enable session reset on login
      it 'explains error'              do do_login; flash[:error].should_not be_nil end
      it "logs the failure"            do controller.logger.should_receive(:warn).with(/failed.*test_login.*0\.0\.0\.0.*\d\d:\d\d:\d\d/i); do_login end
      it "doesn't send password back"  do do_login(:password => 'FROBNOZZ'); response.should_not have_text(/FROBNOZZ/i) end
      it "doesn't log me in"           do do_login; controller.should_not be_logged_in  end
    end

    #
    # Successful login by password
    #
    describe "by password" do
      before(:each) do
        controller.stub!(:handle_remember_cookie!)
        <%= class_name %>.stub!(:authenticate_by_password).with(anything(), anything()).and_return(@user)
        @controller.stub!(:get_authorization).and_return(true)
      end

      describe "successfully" do
        it_should_behave_like "successful login"
        # password
        it "tries login"                                   do controller.should_receive(:login_by_password!).with('test_login', 'monkey'); controller.stub!(:current_user).and_return(@user); do_login end
        it "becomes logged in through the front door"      do controller.should_receive(:become_logged_in_as!).with(@user);               controller.stub!(:current_user).and_return(@user); do_login end
        it "asks to authenticate me"                       do <%= class_name %>.should_receive(:authenticate_by_password).with('test_login', 'monkey'); do_login end
        # cookies
        it "sets cookie with remember me checked"          do controller.should_receive(:handle_remember_cookie!).with(true);  do_login(:remember_me => "1");   end
        it "doesn't set cookie with remember me unchecked" do controller.should_receive(:handle_remember_cookie!).with(false); do_login(:remember_me => "0");  end
        it "doesn't set cookie with remember me bogus"     do controller.should_receive(:handle_remember_cookie!).with(false); do_login(:remember_me => "i_haxxor_joo"); end
        it "doesn't set cookie with remember me blank"     do controller.should_receive(:handle_remember_cookie!).with(false); do_login(:remember_me => "");  end
      end

      #
      # Failed login by password
      #
      handled_errors = [
        [BadPassword,         :renders,      'new',  /password didn't match.*test_login/i],
        [AccountNotFound,     :renders,      'new',  /Can't find account.*test_login/i],
        [AuthenticationError, :redirects_to, '/',    /Problem logging you in.*test_login/i],
        [SecurityError,       :redirects_to, '/',    /SecurityError.*test_login/i ],]
      handled_errors.each do |error_type, error_outcome, error_dest, error_msg|
        describe "on failed login because of #{error_type.to_s.underscore.humanize}" do
          before(:each) do
            <%= class_name %>.stub!(:authenticate_by_password).with(anything(), anything()).and_raise(error_type.new)
          end
          it_should_behave_like "failed login"
          it 'explains error correctly'      do do_login; flash[:error].should =~ error_msg end
          it 'logs out at beginning and end' do controller.should_receive(:logout_keeping_session!).at_least(:twice); do_login end
          it "doesn't touch cookies"         do controller.should_not_receive(:handle_remember_cookie!); do_login end
          case error_outcome
          when :renders then it "#{error_outcome.to_s.humanize} #{error_dest}" do do_login; response.should render_template(error_dest)  end
          else               it "#{error_outcome.to_s.humanize} #{error_dest}" do do_login; response.should redirect_to(error_dest)      end
          end
        end
      end
      describe "on failed login because of an error not related to security" do
        before(:each) do
          <%= class_name %>.stub!(:authenticate_by_password).with(anything(), anything()).and_raise(Exception)
        end
        it "doesn't handle the exception" do lambda{ do_login }.should raise_error(Exception) end
      end
    end
  end

  #
  # Log out
  #
  describe "on logout" do
    def do_logout
      get :destroy
    end

    describe "successful logout", :shared => true do
      it 'logs me out'                   do controller.should_receive(:logout_killing_session!); do_logout end
      it 'sets a flash'                  do do_logout; response.flash[:notice].should =~ /logged out/     end
      it 'redirects me to the home page' do do_logout; response.should be_redirect     end
    end

    it_should_behave_like "successful logout"
  end
end
