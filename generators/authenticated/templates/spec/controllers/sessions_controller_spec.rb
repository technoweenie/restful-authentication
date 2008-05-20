require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe <%= controller_class_name %>Controller do
  fixtures        :<%= table_name %>
  before do 
    @<%= file_name %>  = mock_<%= file_name %>
    @login_params = { :login => 'quentin', :password => 'test' }
    <%= class_name %>.stub!(:authenticate).with(@login_params[:login], @login_params[:password]).and_return(@<%= file_name %>)
  end
  def do_create
    post :create, @login_params
  end
  describe "on successful login," do
    [ [:nil,       nil,            nil],
      [:expired,   'valid_token',  15.minutes.ago],
      [:different, 'i_haxxor_joo', 15.minutes.from_now], 
      [:valid,     'valid_token',  15.minutes.from_now]
        ].each do |has_request_token, token_value, token_expiry|
      [ true, false ].each do |want_remember_me|
        describe "my request cookie token is #{has_request_token.to_s}," do
          describe "and ask #{want_remember_me ? 'to' : 'not to'} be remembered" do 
            before do
              @ccookies = mock('cookies')
              controller.stub!(:cookies).and_return(@ccookies)
              @ccookies.stub!(:[]).with(:auth_token).and_return(token_value)
              @ccookies.stub!(:delete).with(:auth_token)
              @ccookies.stub!(:[]=)
              @<%= file_name %>.stub!(:remember_me) 
              @<%= file_name %>.stub!(:refresh_token) 
              @<%= file_name %>.stub!(:forget_me)
              @<%= file_name %>.stub!(:remember_token).and_return(token_value) 
              @<%= file_name %>.stub!(:remember_token_expires_at).and_return(token_expiry)
              @<%= file_name %>.stub!(:remember_token?).and_return(has_request_token == :valid)
              if want_remember_me
                @login_params[:remember_me] = '1'
              else 
                @login_params[:remember_me] = '0'
              end
            end
            it "kills existing login"        do controller.should_receive(:logout_keeping_session!); do_create; end    
            it "authorizes me"               do do_create; controller.authorized?().should be_true;   end    
            it "logs me in"                  do do_create; controller.logged_in?().should  be_true  end    
            it "greets me nicely"            do do_create; response.flash[:notice].should =~ /success/i   end
            it "sets/resets/expires cookie"  do controller.should_receive(:handle_remember_cookie!).with(want_remember_me); do_create end
            it "sends a cookie"              do controller.should_receive(:send_remember_cookie!);  do_create end
            it 'redirects to the home page'  do do_create; response.should redirect_to('/')   end
            it "does not reset my session"   do controller.should_not_receive(:reset_session).and_return nil; do_create end # change if you uncomment the reset_session path
            if (has_request_token == :valid)
              it 'does not make new token'   do @<%= file_name %>.should_not_receive(:remember_me);   do_create end
              it 'does refresh token'        do @<%= file_name %>.should_receive(:refresh_token);     do_create end 
              it "sets an auth cookie"       do do_create;  end
            else
              if want_remember_me
                it 'makes a new token'       do @<%= file_name %>.should_receive(:remember_me);       do_create end 
                it "does not refresh token"  do @<%= file_name %>.should_not_receive(:refresh_token); do_create end
                it "sets an auth cookie"       do do_create;  end
              else 
                it 'does not make new token' do @<%= file_name %>.should_not_receive(:remember_me);   do_create end
                it 'does not refresh token'  do @<%= file_name %>.should_not_receive(:refresh_token); do_create end 
                it 'kills user token'        do @<%= file_name %>.should_receive(:forget_me);         do_create end 
              end
            end
          end # inner describe
        end
      end
    end
  end
  
  describe "on failed login" do
    before do
      <%= class_name %>.should_receive(:authenticate).with(anything(), anything()).and_return(nil)
      login_as :quentin
    end
    it 'logs out keeping session'   do controller.should_receive(:logout_keeping_session!); do_create end
    it 'flashes an error'           do do_create; flash[:error].should =~ /Couldn't log you in as 'quentin'/ end
    it 'renders the log in page'    do do_create; response.should render_template('new')  end
    it "doesn't log me in"          do do_create; controller.logged_in?().should == false end
    it "doesn't send password back" do 
      @login_params[:password] = 'FROBNOZZ'
      do_create
      response.should_not have_text(/FROBNOZZ/i)
    end
  end

  describe "on signout" do
    def do_destroy
      get :destroy
    end
    before do 
      login_as :quentin
    end
    it 'logs me out'                   do controller.should_receive(:logout_killing_session!); do_destroy end
    it 'redirects me to the home page' do do_destroy; response.should be_redirect     end
  end
  
end

describe <%= controller_class_name %>Controller do
  describe "route generation" do
    it "should route {:controller => '<%= controller_file_path %>', :action => 'new'} to /<%= controller_file_path %>/new" do
      route_for(:controller => '<%= controller_file_path %>', :action => 'new').should == "/<%= controller_file_path %>/new"
    end
    it "should route {:controller => '<%= controller_file_path %>', :action => 'create'} to /<%= controller_file_path %>" do
      route_for(:controller => '<%= controller_file_path %>', :action => 'create').should == "/<%= controller_file_path %>"
    end
    it "should route {:controller => '<%= controller_file_path %>', :action => 'destroy'} to /<%= controller_file_path %>" do
      route_for(:controller => '<%= controller_file_path %>', :action => 'destroy').should == "/<%= controller_file_path %>/destroy"
    end
  end
  
  describe "route recognition" do
    it "should generate params {:controller => '<%= controller_file_path %>', :action => 'new'} from GET /<%= controller_file_path %>" do
      params_from(:get, '/<%= controller_file_path %>/new').should == {:controller => '<%= controller_file_path %>', :action => 'new'}
    end
    it "should generate params {:controller => '<%= controller_file_path %>', :action => 'create'} from POST /<%= controller_file_path %>" do
      params_from(:post, '/<%= controller_file_path %>').should == {:controller => '<%= controller_file_path %>', :action => 'create'}
    end
    it "should generate params {:controller => '<%= controller_file_path %>', :action => 'destroy'} from DELETE /<%= controller_file_path %>" do
      params_from(:delete, '/<%= controller_file_path %>').should == {:controller => '<%= controller_file_path %>', :action => 'destroy'}
    end
  end
  
  describe "named routing" do
    before(:each) do
      get :new
    end
    it "should route <%= table_name %>_path() to /<%= controller_file_path %>" do
      <%= controller_file_name %>_path().should == "/<%= controller_file_path %>"
    end
    it "should route new_<%= table_name.singularize %>_path() to /<%= controller_file_path %>/new" do
      new_<%= controller_table_name.singularize %>_path().should == "/<%= controller_file_path %>/new"
    end
  end
  
end
