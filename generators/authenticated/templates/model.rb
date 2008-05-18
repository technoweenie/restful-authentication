require 'digest/sha1'

class <%= class_name %> < ActiveRecord::Base
  include Authenticated
  include Authenticated::ByPassword

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

  <% if options[:include_activation] && !options[:stateful] %>before_create :make_activation_code <% end %>

  # HACK HACK HACK -- how to do attr_accessible from here?
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
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end<% end %>

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = <% 
    if options[:stateful] %>find_in_state :first, :active, :conditions => {:login => login}<%
    elsif options[:include_activation] %>find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]<% 
    else %>find_by_login(login)<% 
    end %> # need to get the salt
    u && u.authenticated?(password) ? u : nil
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
<% if options[:include_activation] -%>
    def make_activation_code
  <% if options[:stateful] -%>
      self.deleted_at = nil
  <% end -%>
      self.activation_code = self.class.make_token
    end
<% end %>
<% if options[:stateful] -%>
    def do_delete
      self.deleted_at = Time.now.utc
    end

    def do_activate
      @activated = true
      self.activated_at = Time.now.utc
      self.deleted_at = self.activation_code = nil
    end
<% end %>

end
