require 'digest/sha1'
require 'authenticated_system_model'
class <%= class_name %> < DataMapper::Base
  include AuthenticatedSystem::Model
  
  attr_accessor :password, :password_confirmation
  
  property :login,                      :string
  property :email,                      :string
  property :crypted_password,           :string
  property :salt,                       :string
<% if include_activation -%>
  property :activation_code,            :string
  property :activated_at,               :datetime
<% end -%>
  property :remember_token_expires_at,  :datetime
  property :remember_token,             :string
  property :created_at,                 :datetime
  property :updated_at,                 :datetime
  
  validates_length_of         :login,                   :within => 3..40
  validates_uniqueness_of     :login
  validates_presence_of       :email
  # validates_format_of         :email,                   :as => :email_address
  validates_length_of         :email,                   :within => 3..100
  validates_uniqueness_of     :email
  validates_presence_of       :password,                :if => proc {password_required?}
  validates_presence_of       :password_confirmation,   :if => proc {password_required?}
  validates_length_of         :password,                :within => 4..40, :if => proc {password_required?}
  validates_confirmation_of   :password,                :groups => :create
    
  before_save :encrypt_password
<% if include_activation -%>
  before_create :make_activation_code
  after_create :send_signup_notification
<% end -%>
  
  def login=(value)
    @login = value.downcase unless value.nil?
  end
    
<% if include_activation -%>  
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