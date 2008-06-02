#
#
#
# Note that the decision to activate user or assign extra privileges is not made
# here, it is made in the reconcile_privileges! method.
#
#require_dependency 'email_verification/mailer'
#require_dependency 'email_verification/observer'
module Trustification::EmailVerification
  def email_verified?
    # if verified at date exists, they've verified
    not email_verified_at.blank?
  end

protected

  module ClassMethods
    #
    # Finds the user with the corresponding email_verification code,
    # verifies their account,
    # returns the user.
    #
    # Raises:
    #  +User::EmailVerificationCodeBlank+    for blank verification code
    #  +User::EmailVerificationCodeNotFound+ for bogus verification code
    #
    def find_and_verify_email!(email_verification_code)
      raise EmailVerificationCodeMissing if email_verification_code.blank?
      user = find_by_email_verification_code(email_verification_code)
      raise(EmailVerificationCodeNotFound) unless user
      success = user.send(:verify_email!)
      success && user
    end
  end

  # Visitor has verified they own the given email address
  def verify_email!
    self.email_verified_at    = Time.now.utc
    self.email_verification_code = nil
    reconcile_privileges! :email_verified
    success = save(false)
    success
  end

  # before_create: make an unguessable unique token.
  def make_email_verification_code
    self.email_verification_code = self.class.make_token
  end

  #
  # make a verification code for every user created
  #
  def self.included(recipient)
    # puts "email_verification included by #{recipient}"
    recipient.before_create :make_email_verification_code
    recipient.extend ClassMethods
  end
end

require 'authentication/exceptions'
#
# Exceptions
#
class EmailVerificationCodeNotFound < AuthenticationError
  def to_s() "We couldn't find a user with that verification code -- check your email? Or maybe you've already verified your email -- try signing in." end
end
class EmailVerificationCodeMissing  < AuthenticationError
  def to_s() "That verification code was blank.  Please follow the URL from your email, or contact a site admin if there's a problem." end
end
