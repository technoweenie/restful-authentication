# Base error class for Authentication errors
class AuthenticationError < SecurityError
  def to_s() "Problem logging you in" end
end

# If security is more important, you shouldn't say why the login failed, just
# that it did. In this case, comment out the to_s: then each exception will just
# behave like an AuthenticationError
#
# If user experience is more important, give descriptive error messages.

class AccountNotFound < AuthenticationError
  def to_s() "Can't find account" end
end

class BadPassword     < AuthenticationError
  def to_s() "That password didn't match" end
end
