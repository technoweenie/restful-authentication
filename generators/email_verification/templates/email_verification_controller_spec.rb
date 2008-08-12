require File.dirname(__FILE__) + '/../spec_helper'

describe "on activation error" do
    [
      [AccountNotActive, :redirects_to, '/', /hasn't been activated.*look for the email.*contact an admin/i],
    ].each do |error_type, error_outcome, error_dest, error_msg|
      before do
        <%= class_name %>.stub!(:authenticate_by_password).with('user_name', @login_params[:password]).and_return(@user)
        @user.stub!(:active?).and_return(false)
      end
      describe "#{error_type.to_s.underscore.humanize}" do
        it "doesn't log me in"                            do do_login; controller.logged_in?().should == false  end
        it 'explains error correctly'                     do do_login; flash[:error].should =~ error_msg        end
        it "#{error_outcome.to_s.humanize} #{error_dest}" do do_login; response.should redirect_to(error_dest)  end
        it "gets to our resolve_authorization chainlink"  do controller.should_receive(:get_authorization).and_raise error_type; do_login end
      end
    end
  end

describe <%= class_name %> do
  fixtures :<%= table_name %>

  it 'signs up user with activation code' do
    create_user
    assigns(:user).reload
    assigns(:user).activation_code.should_not be_nil
  end

  describe 'being created' do
    before do
      @<%= file_name %> = nil
      @creating_<%= file_name %> = lambda do
        @<%= file_name %> = create_<%= file_name %>
        violated "#{@<%= file_name %>.errors.full_messages.to_sentence}" if @<%= file_name %>.new_record?
      end
    end
    it 'initializes #activation_code' do
      @creating_<%= file_name %>.call
      @<%= file_name %>.reload
      @<%= file_name %>.activation_code.should_not be_nil
    end



  it 'activates user' do
    create_user
    assigns[:user].should_not be_active
    get :activate, :activation_code => <%= table_name %>(:aaron).activation_code
    response.should redirect_to('/session/new')
    flash[:notice].should_not be_nil
    flash[:error ].should     be_nil
    user = <%= class_name %>.authenticate_by_password('aaron', 'monkey')
    user.should be_active
    user.should == <%= table_name %>(:aaron)
  end

  it 'does not activate user without key' do
    get :activate
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end

  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end

  it 'does not activate user with bogus key' do
    get :activate, :activation_code => 'i_haxxor_joo'
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
end
