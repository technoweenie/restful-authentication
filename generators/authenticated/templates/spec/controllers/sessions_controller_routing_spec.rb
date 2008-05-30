require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  describe "route generation" do
    it "should route {:controller => 'sessions', :action => 'new'} correctly"               do route_for(:controller => 'sessions', :action => 'new').should     == "/login" end
    it "should route {:controller => 'sessions', :action => 'create'} correctly"            do route_for(:controller => 'sessions', :action => 'create').should  == "/session" end
    it "should route {:controller => 'sessions', :action => 'destroy'} correctly"           do route_for(:controller => 'sessions', :action => 'destroy').should == "/logout" end
  end

  describe "route recognition" do
    it "should generate params for session 'new'     from GET    /login"       do params_from(:get,    '/login').should    == {:controller => 'sessions', :action => 'new'} end
    it "should generate params for session 'new'     from GET    /session/new" do params_from(:get,    '/login').should    == {:controller => 'sessions', :action => 'new'} end
    it "should generate params for session 'create'  from POST   /session"     do params_from(:post,   '/session').should  == {:controller => 'sessions', :action => 'create'} end
    it "should generate params for session 'destroy' from GET    /logout"      do params_from(:delete, '/logout').should   == {:controller => 'sessions', :action => 'destroy'} end
    it "should generate params for session 'destroy' from DELETE /logout"      do params_from(:delete, '/logout').should   == {:controller => 'sessions', :action => 'destroy'} end
    it "should generate params for session 'destroy' from DELETE /session"     do params_from(:delete, '/logout').should   == {:controller => 'sessions', :action => 'destroy'} end
  end

  describe "named routing" do
    before(:each) do
      get :new
    end
    it "should route session_path() correctly"         do session_path().should         == "/session" end
    it "should route new_session_path() correctly"     do new_session_path().should     == "/session/new" end
    it "should route login_path() correctly"           do login_path().should           == "/login" end
    it "should route logout_path() correctly"          do logout_path().should          == "/logout" end
  end
end
