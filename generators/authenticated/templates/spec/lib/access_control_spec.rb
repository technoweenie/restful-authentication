require File.dirname(__FILE__) + '/../spec_helper'

describe AccessControl do
  #   before(:each) do
  #     @user = mock_user
  #     # set up module rig
  #     @klass = Class.new do
  #       stub!(:rescue_from)
  #       include AccessControl
  #     end
  #     @mockcontroller = @klass.new
  #     # Fake a controller
  #     # @mockcontroller.stub!(:session).and_return( {} )
  #     # @mockcontroller.stub!(:cookies).and_return( {} )
  #     # @mockcontroller.stub!(:reset_session)
  #     # @mockcontroller.stub!(:authenticate_with_http_basic).and_return nil  # FIXME -- session controller not testing xml logins
  #   end
  #
  #
  #   describe "before filters" do
  #     before(:each) do
  #       #
  #       # A test controller with and without access controls
  #       #
  #       @klass.class_eval do
  #
  #

  # describe 'simple authorization' do
  #   it "should not authorize logged-out" do
  #     controller.stub!(:current_user).and_return(false)
  #     controller.authorized?().should be_false
  #   end
  #   it "should authorize logged-in" do
  #     controller.stub!(:current_user).and_return(<%= class_name %>.new)
  #     controller.authorized?().should be_true
  #   end
  # end

  #
  # Exceptions
  #
  describe "exceptions exist with correct type" do
    it "AuthenticationError" do AuthenticationError.should < SecurityError       end
    it "AccountNotFound"     do AccountNotFound.should     < AuthenticationError end
    it "BadPassword"         do BadPassword.should         < AuthenticationError end
  end
end
