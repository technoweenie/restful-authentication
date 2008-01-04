require 'digest/sha1'
require 'authenticated_system_model'
class <%= class_name %> < ActiveRecord::Base
  include AuthenticatedSystem::Model
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
<% if include_activation -%>
  before_create :make_activation_code
  after_create :send_signup_notification
<% end -%>
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation
  
  def login=(login_name)
    self[:login] = login_name.downcase unless login_name.nil?
  end

<% if options[:include_activation] -%>
  EMAIL_FROM = "info@mysite.com"
  SIGNUP_MAIL_SUBJECT = "Welcome to MYSITE.  Please activate your account."
  ACTIVATE_MAIL_SUBJECT = "Welcome to MYSITE"

  # Activates the <%= singular_name %> in the database
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save

    # send mail for activation
    <%= class_name %>Mailer.dispatch_and_deliver(  :activation_notification,
                                  {   :from => <%= class_name %>::EMAIL_FROM,
                                      :to   => self.email,
                                      :subject => <%= class_name %>::ACTIVATE_MAIL_SUBJECT },

                                      :<%= singular_name %> => self )

  end

  def send_signup_notification
    <%= class_name %>Mailer.dispatch_and_deliver(
        :signup_notification,
      { :from => <%= class_name %>::EMAIL_FROM,
        :to  => self.email,
        :subject => <%= class_name %>::SIGNUP_MAIL_SUBJECT },
        :<%= singular_name %> => self        
    )
  end

<% end -%>
end
