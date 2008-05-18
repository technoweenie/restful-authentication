require 'digest/sha1'

# Uncomment to suit
# RE_LOGIN_OK   = /\A[[:alnum:]][[:alnum:]\.\-_@]+\z/     # Unicode, strict
RE_LOGIN_OK     = /\A\w[\w\.\-_@]+\z/                     # ASCII, strict
MSG_LOGIN_BAD   = "use only letters, numbers, and .-_@ please."

RE_NAME_OK      = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
MSG_NAME_BAD    = "avoid non-printing characters and \\&gt;&lt;&amp;/ please."

# This is purposefully imperfect -- it's just a check for bogus input. See
# http://www.regular-expressions.info/email.html
#RE_EMAIL_NAME   = '0-9A-Z!#\$%\&\'\*\+_/=\?^\-`\{|\}~\.' # technically allowed by RFC-2822
RE_EMAIL_NAME   = '[\w\.%\+\-]+'                          # what you actually see in practice
RE_DOMAIN_HEAD  = '(?:[A-Z0-9\-]+\.)+'
RE_DOMAIN_TLD   = '(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
RE_EMAIL_OK     = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
MSG_EMAIL_BAD   = "should look like an email address."


class <%= class_name %> < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,    :case_sensitive => false
  validates_format_of       :login,    :with => RE_LOGIN_OK, :message => MSG_LOGIN_BAD

  validates_format_of       :name,     :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD

  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :password, :within => 6..40, :if => :password_required?
  before_save :encrypt_password
  
  <% if options[:include_activation] && !options[:stateful] %>before_create :make_activation_code <% end %>

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation

<% if options[:stateful] %>
  acts_as_state_machine :initial => :pending
  state :passive
  state :pending, :enter => :make_activation_code
  state :active,  :enter => :do_activate
  state :suspended
  state :deleted, :enter => :do_delete

  event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  event :activate do
    transitions :from => :pending, :to => :active 
  end
  
  event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end
<% elsif options[:include_activation] %>
  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end
<% end %>
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = <% 
    if options[:stateful] %>find_in_state :first, :active, :conditions => {:login => login}<%
    elsif options[:include_activation] %>find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]<% 
    else %>find_by_login(login)<% 
    end %> # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    (!remember_token.blank?) && 
      remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = self.class.make_token
    save(false)
  end

  # refresh token (keeping same expires_at) if it exists
  def refresh_token
    if remember_token?
      self.remember_token = self.class.make_token 
      save(false)      
    end
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

<% if options[:stateful] -%>
  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
<% end -%>

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = self.class.make_token if new_record?
      self.crypted_password = encrypt(password)
    end
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    <% if options[:include_activation] %>
    def make_activation_code
<% if options[:stateful] -%>
      self.deleted_at = nil<% end %>
      self.activation_code = self.class.make_token
    end<% end %>
    <% if options[:stateful] %>
    def do_delete
      self.deleted_at = Time.now.utc
    end

    def do_activate
      @activated = true
      self.activated_at = Time.now.utc
      self.deleted_at = self.activation_code = nil
    end<% end %>

    # Encrypts the password with the user salt
    def encrypt(password)
      self.class.password_digest(password, salt)
    end

    # Backwards-compatible; replace call to "password_digest" with "old_password_digest"
    def self.old_password_digest(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end
    
    # This provides a modest increased defense against a dictionary attack if
    # your db were ever compromised, but will invalidate existing passwords.
    # See the README.
    def self.password_digest(password, salt)
      digest = REST_AUTH_SITE_KEY
      REST_AUTH_DIGEST_STRETCHES.times do
        digest = secure_digest(salt, digest, password, REST_AUTH_SITE_KEY)
      end
      digest
    end
    
    def self.secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join('&&'))
    end

    def self.make_token
      secure_digest(Time.now, (1..10).map{ rand.to_s })
    end 
end
