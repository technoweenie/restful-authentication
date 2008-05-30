# Stolen from Ben Mabey
# http://www.benmabey.com/2008/02/04/rspec-plain-text-stories-webrat-chunky-bacon/

# These allow exceptions to come through as opposed to being caught and hvaing non-helpful responses returned.
ActionController::Base.class_eval do
  def perform_action
    perform_action_without_rescue
  end
end
Dispatcher.class_eval do
  def self.failsafe_response(output, status, exception = nil)
    raise exception
  end
end
