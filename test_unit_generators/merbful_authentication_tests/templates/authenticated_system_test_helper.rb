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

# Assert difference(s) methods were taken from RubyOnRails to support the port of restful_authentication

def assert_difference(expressions, difference = 1, message = nil, &block)
  expression_evaluations = Array(expressions).collect{ |expression| lambda { eval(expression, block.send(:binding)) } }

  original_values = expression_evaluations.inject([]) { |memo, expression| memo << expression.call }
  yield
  expression_evaluations.each_with_index do |expression, i|
    assert_equal original_values[i] + difference, expression.call, message
  end
end

def assert_no_difference(expressions, message = nil, &block)
  assert_difference expressions, 0, message, &block
end


def assert_response(code = :success)
  case code
  when :success
    assert_equal 200, controller.status
  when :redirect
    assert_equal 302, controller.status
  end
end


