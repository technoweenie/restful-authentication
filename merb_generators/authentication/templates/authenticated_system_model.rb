require 'authenticated_system_orm_map'
module AuthenticatedSystem
  module Model
    
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend,  ClassMethods)
      base.send(:extend,  AuthenticatedSystem::OrmMap )
    end
    
    module InstanceMethods
      def authenticated?(password)
        crypted_password == encrypt(password)
      end      

      # before filter 
      def encrypt_password
        return if password.blank?
        self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
        self.crypted_password = encrypt(password)
      end
      
      # Encrypts the password with the <%= singular_name %> salt
      def encrypt(password)
        self.class.encrypt(password, salt)
      end
      
      def remember_token?
        remember_token_expires_at && DateTime.now < DateTime.parse(remember_token_expires_at.to_s)
      end

      def remember_me_until(time)
        self.remember_token_expires_at = time
        self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
        save
      end

      def remember_me_for(time)
        remember_me_until (Time.now + time)
      end

      # These create and unset the fields required for remembering <%= singular_name %>s between browser closes
      # Default of 2 weeks 
      def remember_me
        remember_me_for (Merb::Const::WEEK * 2)
      end

      def forget_me
        self.remember_token_expires_at = nil
        self.remember_token            = nil
        self.save
      end
      <% if include_activation -%>
      # Returns true if the <%= singular_name %> has just been activated.
      def recently_activated?
        @activated
      end

      def activated?
       return false if self.new_record?
       !! activation_code.nil?
      end

      def active?
        # the existence of an activation code means they have not activated yet
        activation_code.nil?
      end
      <% end %>
      protected
      <% if include_activation -%>
      def make_activation_code
        self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      end
      <% end -%>

      def password_required?
        crypted_password.blank? || !password.blank?
      end
            
    end
    
    module ClassMethods
      # Encrypts some data with the salt.
      def encrypt(password, salt)
        Digest::SHA1.hexdigest("--#{salt}--#{password}--")
      end
      
      # Authenticates a <%= singular_name %> by their login name and unencrypted password.  Returns the <%= singular_name %> or nil.
      def authenticate(login, password)
        u = find_activated_authenticated_model_with_login(login) # need to get the salt
        u && u.authenticated?(password) ? u : nil
      end
    end

    
  end
end