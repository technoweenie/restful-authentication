module Authenticated
  module ByPassword
    # Constants

    # 
    def self.included( recipient )
      recipient.extend( ByPasswordClassMethods )
      recipient.class_eval do
        # Virtual attribute for the unencrypted password
        attr_accessor :password
        validates_presence_of     :password,                   :if => :password_required?
        validates_presence_of     :password_confirmation,      :if => :password_required?
        validates_confirmation_of :password,                   :if => :password_required?
        validates_length_of       :password, :within => 6..40, :if => :password_required?
        before_save :encrypt_password
        
        include ByPasswordInstanceMethods
      end
    end

    #
    # Class Methods
    #
    module ByPasswordClassMethods
      # Backwards-compatible; replace call to "password_digest" with "old_password_digest"
      def old_password_digest(password, salt)
        Digest::SHA1.hexdigest("--#{salt}--#{password}--")
      end      
      # This provides a modest increased defense against a dictionary attack if
      # your db were ever compromised, but will invalidate existing passwords.
      # See the README.
      def password_digest(password, salt)
        digest = REST_AUTH_SITE_KEY
        REST_AUTH_DIGEST_STRETCHES.times do
          digest = secure_digest(salt, digest, password, REST_AUTH_SITE_KEY)
        end
        digest
      end      
    end
    
    #
    # Instance Methods
    #
    module ByPasswordInstanceMethods
      # Encrypts the password with the user salt
      def encrypt(password)
        self.class.password_digest(password, salt)
      end


      def authenticated?(password)
        crypted_password == encrypt(password)
      end
      
      # before filter 
      def encrypt_password
        return if password.blank?
        self.salt = self.class.make_token if new_record?
        self.crypted_password = encrypt(password)
      end
      def password_required?
        crypted_password.blank? || !password.blank?
      end
      
    end

  end
end
