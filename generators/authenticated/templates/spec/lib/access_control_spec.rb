require File.dirname(__FILE__) + '/../spec_helper'

describe AccessControl do
  # before(:each) do
  # end
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
