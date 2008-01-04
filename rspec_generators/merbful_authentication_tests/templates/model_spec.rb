require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "<%= singular_name %>_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe <%= class_name %> do
  include <%= class_name %>SpecHelper
  
  before(:each) do
    <%= class_name %>.clear_database_table
<% if include_activation -%>
    <%= class_name %>Mailer.stub!(:activation_notification).and_return(true)
<% end -%>
  end

  it "should have a login field" do
    <%= singular_name %> = <%= class_name %>.new
    <%= singular_name %>.should respond_to(:login)
    <%= singular_name %>.valid?
    <%= singular_name %>.errors.on(:login).should_not be_nil
  end
  
  it "should fail login if there are less than 3 chars" do
    <%= singular_name %> = <%= class_name %>.new
    <%= singular_name %>.login = "AB"
    <%= singular_name %>.valid?
    <%= singular_name %>.errors.on(:login).should_not be_nil
  end
  
  it "should not fail login with between 3 and 40 chars" do
    <%= singular_name %> = <%= class_name %>.new
    [3,40].each do |num|
      <%= singular_name %>.login = "a" * num
      <%= singular_name %>.valid?
      <%= singular_name %>.errors.on(:login).should be_nil
    end
  end
  
  it "should fail login with over 90 chars" do
    <%= singular_name %> = <%= class_name %>.new
    <%= singular_name %>.login = "A" * 41
    <%= singular_name %>.valid?
    <%= singular_name %>.errors.on(:login).should_not be_nil    
  end
  
  it "should make a valid <%= singular_name %>" do
    <%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash)
    <%= singular_name %>.save
    <%= singular_name %>.errors.should be_empty
    
  end
  
  it "should make sure login is unique" do
    <%= singular_name %> = <%= class_name %>.new( valid_<%= singular_name %>_hash.with(:login => "Daniel") )
    <%= singular_name %>2 = <%= class_name %>.new( valid_<%= singular_name %>_hash.with(:login => "Daniel"))
    <%= singular_name %>.save.should be_true
    <%= singular_name %>.login = "Daniel"
    <%= singular_name %>2.save.should be_false
    <%= singular_name %>2.errors.on(:login).should_not be_nil
  end
  
  it "should make sure login is unique regardless of case" do
    <%= class_name %>.find_with_conditions(:login => "Daniel").should be_nil
    <%= singular_name %> = <%= class_name %>.new( valid_<%= singular_name %>_hash.with(:login => "Daniel") )
    <%= singular_name %>2 = <%= class_name %>.new( valid_<%= singular_name %>_hash.with(:login => "daniel"))
    <%= singular_name %>.save.should be_true
    <%= singular_name %>.login = "Daniel"
    <%= singular_name %>2.save.should be_false
    <%= singular_name %>2.errors.on(:login).should_not be_nil
  end
  
  it "should downcase logins" do
    <%= singular_name %> = <%= class_name %>.new( valid_<%= singular_name %>_hash.with(:login => "DaNieL"))
    <%= singular_name %>.login.should == "daniel"    
  end  
  
  it "should authenticate a <%= singular_name %> using a class method" do
    <%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash)
    <%= singular_name %>.save
<% if include_activation -%>
    <%= singular_name %>.activate
<% end -%>
    <%= class_name %>.authenticate(valid_<%= singular_name %>_hash[:login], valid_<%= singular_name %>_hash[:password]).should_not be_nil
  end
  
  it "should not authenticate a <%= singular_name %> using the wrong password" do
    <%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash)  
    <%= singular_name %>.save
<% if include_activation -%>  
    <%= singular_name %>.activate
<% end -%>
    <%= class_name %>.authenticate(valid_<%= singular_name %>_hash[:login], "not_the_password").should be_nil
  end
  
  it "should not authenticate a <%= singular_name %> using the wrong login" do
    <%= singular_name %> = <%= class_name %>.create(valid_<%= singular_name %>_hash)  
<% if include_activation -%>  
    <%= singular_name %>.activate
<% end -%>
    <%= class_name %>.authenticate("not_the_login", valid_<%= singular_name %>_hash[:password]).should be_nil
  end
  
  it "should not authenticate a <%= singular_name %> that does not exist" do
    <%= class_name %>.authenticate("i_dont_exist", "password").should be_nil
  end
  
<% if include_activation -%> 
  it "should send a please activate email" do
    <%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash)
    <%= class_name %>Mailer.should_receive(:dispatch_and_deliver) do |action, mail_args, mailer_params|
      action.should == :signup_notification
      [:from, :to, :subject].each{ |f| mail_args.keys.should include(f)}
      mail_args[:to].should == <%= singular_name %>.email
      mailer_params[:<%= singular_name %>].should == <%= singular_name %>
    end
    <%= singular_name %>.save
  end
  
  it "should not send a please activate email when updating" do
    <%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash)
    <%= singular_name %>.save
    <%= class_name %>Mailer.should_not_receive(:signup_notification)
    <%= singular_name %>.login = "not in the valid hash for login"
    <%= singular_name %>.save    
  end
<% end -%>  
end

describe <%= class_name %>, "the password fields for <%= class_name %>" do
  include <%= class_name %>SpecHelper
  
  before(:each) do
    <%= class_name %>.clear_database_table
    @<%= singular_name %> = <%= class_name %>.new( valid_<%= singular_name %>_hash )
<% if include_activation -%>
    <%= class_name %>Mailer.stub!(:activation_notification).and_return(true)
<% end -%>
  end
  
  it "should respond to password" do
    @<%= singular_name %>.should respond_to(:password)    
  end
  
  it "should respond to password_confirmation" do
    @<%= singular_name %>.should respond_to(:password_confirmation)
  end
  
  it "should have a protected password_required method" do
    @<%= singular_name %>.protected_methods.should include("password_required?")
  end
  
  it "should respond to crypted_password" do
    @<%= singular_name %>.should respond_to(:crypted_password)    
  end
  
  it "should require password if password is required" do
    <%= singular_name %> = <%= class_name %>.new( valid_<%= singular_name %>_hash.without(:password))
    <%= singular_name %>.stub!(:password_required?).and_return(true)
    <%= singular_name %>.valid?
    <%= singular_name %>.errors.on(:password).should_not be_nil
    <%= singular_name %>.errors.on(:password).should_not be_empty
  end
  
  it "should set the salt" do
    <%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash)
    <%= singular_name %>.salt.should be_nil
    <%= singular_name %>.send(:encrypt_password)
    <%= singular_name %>.salt.should_not be_nil    
  end
  
  it "should require the password on create" do
    <%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash.without(:password))
    <%= singular_name %>.save
    <%= singular_name %>.errors.on(:password).should_not be_nil
    <%= singular_name %>.errors.on(:password).should_not be_empty
  end  
  
  it "should require password_confirmation if the password_required?" do
    <%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash.without(:password_confirmation))
    <%= singular_name %>.save
    (<%= singular_name %>.errors.on(:password) || <%= singular_name %>.errors.on(:password_confirmation)).should_not be_nil
  end
  
  it "should fail when password is outside 4 and 40 chars" do
    [3,41].each do |num|
      <%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash.with(:password => ("a" * num)))
      <%= singular_name %>.valid?
      <%= singular_name %>.errors.on(:password).should_not be_nil
    end
  end
  
  it "should pass when password is within 4 and 40 chars" do
    [4,30,40].each do |num|
      <%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash.with(:password => ("a" * num), :password_confirmation => ("a" * num)))
      <%= singular_name %>.valid?
      <%= singular_name %>.errors.on(:password).should be_nil
    end    
  end
  
  it "should autenticate against a password" do
    <%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash)
    <%= singular_name %>.save    
    <%= singular_name %>.should be_authenticated(valid_<%= singular_name %>_hash[:password])
  end
  
  it "should not require a password when saving an existing <%= singular_name %>" do
    <%= singular_name %> = <%= class_name %>.create(valid_<%= singular_name %>_hash)
    <%= singular_name %> = <%= class_name %>.find_with_conditions(:login => valid_<%= singular_name %>_hash[:login])
    <%= singular_name %>.password.should be_nil
    <%= singular_name %>.password_confirmation.should be_nil
    <%= singular_name %>.login = "some_different_login_to_allow_saving"
    (<%= singular_name %>.save).should be_true
  end
  
end

<% if include_activation -%>
describe <%= class_name %>, "activation" do
  include <%= class_name %>SpecHelper
  
  
  before(:each) do
    <%= class_name %>.clear_database_table
    @<%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash)
  end
  
  it "should have an activation_code as an attribute" do
    @<%= singular_name %>.attributes.keys.any?{|a| a.to_s == "activation_code"}.should_not be_nil
  end
  
  it "should create an activation code on create" do
    @<%= singular_name %>.activation_code.should be_nil    
    @<%= singular_name %>.save
    @<%= singular_name %>.activation_code.should_not be_nil
  end
  
  it "should not be active when created" do
    @<%= singular_name %>.should_not be_activated
    @<%= singular_name %>.save
    @<%= singular_name %>.should_not be_activated    
  end
  
  it "should respond to activate" do
    @<%= singular_name %>.should respond_to(:activate)    
  end
  
  it "should activate a <%= singular_name %> when activate is called" do
    @<%= singular_name %>.should_not be_activated
    @<%= singular_name %>.save
    @<%= singular_name %>.activate
    @<%= singular_name %>.should be_activated
    <%= class_name %>.find_with_conditions(:login => valid_<%= singular_name %>_hash[:login]).should be_activated
  end
  
  it "should should show recently activated when the instance is activated" do
    @<%= singular_name %>.should_not be_recently_activated
    @<%= singular_name %>.activate
    @<%= singular_name %>.should be_recently_activated
  end
  
  it "should not show recently activated when the instance is fresh" do
    @<%= singular_name %>.activate
    @<%= singular_name %> = nil
    <%= class_name %>.find_with_conditions(:login => valid_<%= singular_name %>_hash[:login]).should_not be_recently_activated
  end
  
  it "should send out a welcome email to confirm that the account is activated" do
    @<%= singular_name %>.save
    <%= class_name %>Mailer.should_receive(:dispatch_and_deliver) do |action, mail_args, mailer_params|
      action.should == :activation_notification
      mail_args.keys.should include(:from)
      mail_args.keys.should include(:to)
      mail_args.keys.should include(:subject)
      mail_args[:to].should == @<%= singular_name %>.email
      mailer_params[:<%= singular_name %>].should == @<%= singular_name %>
    end
    @<%= singular_name %>.activate
  end
  
end
<% end -%>

describe <%= class_name %>, "remember_me" do
  include <%= class_name %>SpecHelper
  
  predicate_matchers[:remember_token] = :remember_token?
  
  before do
    <%= class_name %>.clear_database_table
    @<%= singular_name %> = <%= class_name %>.new(valid_<%= singular_name %>_hash)
  end
  
  it "should have a remember_token_expires_at attribute" do
    @<%= singular_name %>.attributes.keys.any?{|a| a.to_s == "remember_token_expires_at"}.should_not be_nil
  end  
  
  it "should respond to remember_token?" do
    @<%= singular_name %>.should respond_to(:remember_token?)
  end
  
  it "should return true if remember_token_expires_at is set and is in the future" do
    @<%= singular_name %>.remember_token_expires_at = DateTime.now + 3600
    @<%= singular_name %>.should remember_token    
  end
  
  it "should set remember_token_expires_at to a specific date" do
    time = Time.mktime(2009,12,25)
    @<%= singular_name %>.remember_me_until(time)
    @<%= singular_name %>.remember_token_expires_at.should == time    
  end
  
  it "should set the remember_me token when remembering" do
    time = Time.mktime(2009,12,25)
    @<%= singular_name %>.remember_me_until(time)
    @<%= singular_name %>.remember_token.should_not be_nil
    @<%= singular_name %>.save
    <%= class_name %>.find_with_conditions(:login => valid_<%= singular_name %>_hash[:login]).remember_token.should_not be_nil
  end
  
  it "should remember me for" do
    t = Time.now
    Time.stub!(:now).and_return(t)
    today = Time.now
    remember_until = today + (2* Merb::Const::WEEK)
    @<%= singular_name %>.remember_me_for( Merb::Const::WEEK * 2)
    @<%= singular_name %>.remember_token_expires_at.should == (remember_until)
  end
  
  it "should remember_me for two weeks" do
    t = Time.now
    Time.stub!(:now).and_return(t)
    @<%= singular_name %>.remember_me
    @<%= singular_name %>.remember_token_expires_at.should == (Time.now + (2 * Merb::Const::WEEK ))
  end
  
  it "should forget me" do
    @<%= singular_name %>.remember_me
    @<%= singular_name %>.save
    @<%= singular_name %>.forget_me
    @<%= singular_name %>.remember_token.should be_nil
    @<%= singular_name %>.remember_token_expires_at.should be_nil    
  end
  
  it "should persist the forget me to the database" do
    @<%= singular_name %>.remember_me
    @<%= singular_name %>.save
    
    @<%= singular_name %> = <%= class_name %>.find_with_conditions(:login => valid_<%= singular_name %>_hash[:login])
    @<%= singular_name %>.remember_token.should_not be_nil
    
    @<%= singular_name %>.forget_me

    @<%= singular_name %> = <%= class_name %>.find_with_conditions(:login => valid_<%= singular_name %>_hash[:login])
    @<%= singular_name %>.remember_token.should be_nil
    @<%= singular_name %>.remember_token_expires_at.should be_nil
  end
  
end