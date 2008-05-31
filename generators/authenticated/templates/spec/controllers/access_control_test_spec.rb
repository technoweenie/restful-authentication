require File.dirname(__FILE__) + '/../spec_helper'

#
# Constructs a fake class with access controls and checks that the authorization
# response is handled correctly
#

class AccessControlTestController < ActionController::Base
  security_components :security_policy, :authentication => [:by_cookie_token, :by_password],
    :access_control => :login_required
  before_filter :login_required,        :only => :login_is_required
  before_filter :authorization_filter!, :only => :should_demand_authorization
  def login_is_required
    handle_request "login_is_required"
  end
  def should_demand_authorization
    handle_request 'should_demand_authorization'
  end
  def login_not_required
    handle_request 'login_not_required'
  end
  def handle_request desc
    respond_to do |format|
      @foo = { "success" => params[:format]||'no fmt given', "desc" => desc }
      format.html do render :text => @foo.inspect             end
      format.xml  do render :xml  => @foo, :status => :ok  end
      format.json do render :json => @foo, :status => :ok  end
    end
  end
  public :logged_in?, :logout_keeping_session!
end

#
# Access Control
#
# Sketch your access control matrix here:
#
REQUEST_OUTCOMES = [
  [:quentin,       :login_is_required,             :success ],
  [:quentin,       :login_not_required,            :success ],
  [:quentin,       :should_demand_authorization,   :success ],
  [nil,            :login_is_required,             :access_denied],
  [nil,            :login_not_required,            :success ],
  [nil,            :should_demand_authorization,   :access_denied],
]

# formats
ACCESS_CONTROL_FORMATS = [
  ['',     'success'],
  ['xml',  '<success>xml</success>'],
  ['json', '"success": "json"'],
]

describe AccessControlTestController do
  fixtures        :<%= fixtures_name %>
  before do
    ActionController::Routing::Routes.add_route '/login_is_required',  :controller => 'access_control_test', :action => 'login_is_required'
    ActionController::Routing::Routes.add_route '/login_not_required', :controller => 'access_control_test', :action => 'login_not_required'
    ActionController::Routing::Routes.add_route '/should_demand_authorization', :controller => 'access_control_test', :action => 'should_demand_authorization'
    controller.stub!(:cookies).and_return( {} )
    controller.request.stub!(:session).and_return( {} )
    controller.request.stub!(:env).and_return( {} )
  end

  # Outcome #1: Success
  describe "successful request", :shared => true do
    it "succeeds" do
      response.should have_text( /#{@success_text}/ )
      response.should have_text( /#{@page_request}/ )
      response.code.to_s.should == '200'
    end
  end
  # Outcome #2: Access denied
  describe "HTML request and access denied", :shared => true do
    it "redirects me to the log in page" do response.should redirect_to('/session/new') end
  end
  describe "formatted request and access denied", :shared => true do
    it "returns 'Access denied'"                 do response.should have_text("HTTP Basic: Access denied.\n") end
    it "sends a 406 (Access Denied) status code" do response.code.to_s.should == '401' end
  end

  ACCESS_CONTROL_FORMATS.each do |format, success_text|
    REQUEST_OUTCOMES.each do |login_string, page_request, expected_result|
      spec_description  = "requesting #{page_request}.#{format} "
      spec_description += "should give '#{success_text}' "
      spec_description += (login_string.blank? ? 'not logged in' : "logged in as #{login_string}")
      describe spec_description do
        before do
          controller.logout_keeping_session!
          controller.stub!(:current_user).and_return(login_string ? <%= fixtures_name %>(login_string) : false)
          @page_request = page_request
          @success_text = success_text
          get page_request.to_s, :format => format
        end
        case expected_result
        when :success
          it_should_behave_like "successful request"
        when :access_denied
          if format == '' then it_should_behave_like "HTML request and access denied"
          else                 it_should_behave_like "formatted request and access denied"
          end
        end
      end
    end # cases
  end

end
