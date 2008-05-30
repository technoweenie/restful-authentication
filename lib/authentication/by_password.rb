module Authentication::ByPassword
protected

  #
  # Log in using password
  #
  # Ensure you "Fail Closed" -- that **you allot no privileged resources**
  # (assign to current_user, set a cookie, arm nukes, etc.) until this succeeds.
  # See the caveats in become_logged_in_as!
  #
  def login_by_password! login, password
    user = User.authenticate_by_password login, password
    become_logged_in_as! user
  end

  #
  # Called from #current_user, attempts to login by basic authentication.
  #
  def login_from_basic_auth
    authenticate_with_http_basic do |login, password|
      login_by_password! login, password
    end
  end
  # hooks into login chain at lower priority
  def try_login_chain_with_basic_auth
    try_login_chain_without_basic_auth || login_from_basic_auth
  end

  #
  # Plumbing
  #
  def self.included recipient
    # Filters :password and :password_confirmation
    recipient.filter_parameter_logging :password if recipient.respond_to? :filter_parameter_logging
    recipient.alias_method_chain :try_login_chain,  :basic_auth unless recipient.instance_methods.include? 'try_login_chain_without_basic_auth'
  end
end

#
# User model password functionality.
#
module Identity::Password
  def self.included( recipient )
    # puts "#{recipient}: including Authentication::ByPassword"
    recipient.extend( ClassMethods )
    recipient.class_eval do
      attr_accessible :password, :password_confirmation
      # Virtual attribute for the unencrypted password
      attr_accessor :password
      validates_presence_of     :password,                   :if => :password_validation_required?
      validates_presence_of     :password_confirmation,      :if => :password_validation_required?
      validates_confirmation_of :password,                   :if => :password_validation_required?
      validates_length_of       :password, :within => 6..40, :if => :password_validation_required?
      before_save :encrypt_password
    end
  end

  # Does this password match the user's?
  def password_valid?(plaintext)
    crypted_password == encrypt(plaintext)
  end

protected
  # Encrypts the password with the user salt
  def encrypt(plaintext)
    self.class.password_digest(plaintext, salt)
  end

  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = self.class.make_token if new_record?
    self.crypted_password = encrypt(password)
  end
  def password_validation_required?
    crypted_password.blank? || !password.blank?
  end

  module ClassMethods
    # Authenticates a user by their login name and unencrypted password.
    # Returns the user or nil.
    #
    def authenticate_by_password(login, plaintext)
      user = find_by_login(login)
      raise AccountNotFound  unless user
      raise BadPassword      unless user.password_valid?(plaintext)
      user
    end

    #
    # Repeatedly hash the plaintext-password, the user-specific salt, and our site
    # key to produce the encrypted password
    #
    # It may not be obvious, but if you set REST_AUTH_SITE_KEY to nil and
    # REST_AUTH_DIGEST_STRETCHES to 1 you'll have backwards compatibility with
    # older versions of restful-authentication.
    # See the README and the file config/initializers/site_keys.rb
    def password_digest(plaintext, salt)
      digest = REST_AUTH_SITE_KEY
      REST_AUTH_DIGEST_STRETCHES.times do
        digest = secure_digest(digest, salt, plaintext, REST_AUTH_SITE_KEY)
      end
      digest
    end
  end # class methods

end
