require File.dirname(__FILE__) + '/../spec_helper'


describe User do
  describe "when a new user is created" do
    it "has no email_validated_at"
    it "creates an email_validation_code"
      # should_receive(:make_token)
    it "does not has_role?(:email_validated)"
  end

  describe "validate_email!" do
    it "sets email_validated_at"
    it "deletes the email_validation_code"
    it "now has_role?(:email_validated)"
  end

  describe "a user with not-yet-validated email" do
    # if policy is such:
    it "is not active"
    it "cannot log in"
    it "is not authorized for a generic action"
  end
end


