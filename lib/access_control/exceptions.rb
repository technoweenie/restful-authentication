# Base error class for AccessControl errors
class AuthorizationError < SecurityError
  def to_s() "No Yuo." end
end

class AccessDenied       < AuthorizationError
  def to_s() "You're restricted from doing that. Contact an admin if you believe this is incorrect." end
end

class AccountNotActive    < AuthorizationError
  def to_s() "Your account is inactive.  Please follow the activation procedure, or contact an admin for help." end
end
