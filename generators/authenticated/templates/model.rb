require 'digest/sha1'

class <%= class_name %> < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
<% if options[:aasm] -%>
  include Authorization::AasmRoles
<% elsif options[:stateful] -%>
  include Authorization::StatefulRoles<% end %>
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

<% if options[:include_activation] && !options[:stateful] %>
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
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    u = <% if    options[:stateful]           %>find_in_state :first, :active, :conditions => {:login => login}<%
           elsif options[:include_activation] %>find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]<%
           else %>find_by_login(login)<% end %> # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  protected
    
<% if options[:include_activation] -%>
    def make_activation_code
  <% if options[:stateful] -%>
      self.deleted_at = nil
  <% end -%>
      self.activation_code = self.class.make_token
    end
<% end %>

end
