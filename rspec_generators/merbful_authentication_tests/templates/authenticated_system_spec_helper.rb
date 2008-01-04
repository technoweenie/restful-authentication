class Merb::Controller
  require "merb/session/memory_session"
  Merb::MemorySessionContainer.setup
  include ::Merb::SessionMixin
  self.session_secret_key = "foo to the bar to the baz"
end

class Merb::Mailer
  self.delivery_method = :test_send
end

class Hash
  
  def with( opts )
    self.merge(opts)
  end
  
  def without(*args)
    self.dup.delete_if{ |k,v| args.include?(k)}
  end
  
end