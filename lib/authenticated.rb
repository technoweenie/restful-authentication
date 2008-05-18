module Authenticated
  unless Object.constants.include? "AUTHENTICATED_CONSTANTS_DEFINED"
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
    
    AUTHENTICATED_CONSTANTS_DEFINED = 'yup'
  end
  
  def self.included( recipient )
    recipient.extend( AuthenticatedClassMethods )
    recipient.class_eval do
      include AuthenticatedInstanceMethods
    end
  end

  module AuthenticatedClassMethods
    def secure_digest(*args)
      Digest::SHA1.hexdigest(args.flatten.join('&&'))
    end
    def make_token
      secure_digest(Time.now, (1..10).map{ rand.to_s })
    end 
  end
  
  module AuthenticatedInstanceMethods
    
  end

end
