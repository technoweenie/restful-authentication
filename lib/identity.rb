module Identity

  module ModelClassMethods
    #
    # Create a secure one-way hash of the input.
    #
    # The restful-authentication/notes/Tradeoffs.txt file gives a brief
    # description of the tradeoffs involved with this function.
    def secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join('--'))
    end

    #
    # Create a non-repeatable, unguessable identification token for short-lived
    # authentication or digest salt.
    #
    def make_token
      secure_digest(Time.now, (1..10).map{ rand.to_s })
    end
  end

  #
  # Define any user roles here -- eg :moderator or :admin.
  #
  # This example gives every user two roles: :user and :active, and no other.
  #
  # This is just a stub called by the authorization routines.  Add logic over
  # there if you want these roles to do anything.  For more complex needs, see
  # notes/RailsPlugins.txt for role-based security plugins
  #
  def has_role? role
    [:user, :active].include? role
  end

  
  #
  # Validations
  #
  # restful-authentication/notes/Tradeoffs.txt has more information on how these
  # validation formats were chosen.

  #
  # Login (username) format
  #
  MSG_LOGIN_BAD      = "use only letters, numbers, and .-_@ please, and start with a letter."
  RE_LOGIN_OK        = /\A\w[\w\.\-_@]+\z/                     # ASCII, strict
  RE_LOGIN_OK_UC     = /\A[[:alnum:]][[:alnum:]\.\-_@]+\z/     # Unicode, strict
  RE_LOGIN_LIBERAL   = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive

  #
  # Email address format
  #
  # This is purposefully imperfect -- it's just a check for bogus input. See
  # http://www.regular-expressions.info/email.html
  MSG_EMAIL_BAD      = "should look like an email address (you@somethingsomething.com) and include only letters, numbers and .%+- please."
  RE_EMAIL_NAME      = '[\w\.%\+\-]+'                          # what you actually see in practice
  RE_EMAIL_N_RFC2822 = '0-9A-Z!#\$%\&\'\*\+_/=\?^\-`\{|\}~\.' # technically allowed by RFC-2822
  RE_DOMAIN_HEAD     = '(?:[A-Z0-9\-]+\.)+'
  RE_DOMAIN_TLD      = '(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RE_EMAIL_OK        = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
  RE_EMAIL_RFC2822   = /\A#{RE_EMAIL_N_RFC2822}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i

  #
  # Full name format
  #
  MSG_NAME_BAD      = "avoid non-printing characters as well as &amp;\\&lt;&gt;/ please."
  RE_NAME_OK        = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive

  def self.included recipient
    recipient.extend( ModelClassMethods )
  end
end
