require File.dirname(__FILE__) + '/../test_helper'
require (File.dirname(__FILE__) / '../authenticated_system_test_helper')
require (File.dirname(__FILE__) / ".." / "<%= singular_name %>_test_helper")
include <%= class_name %>TestHelper

class <%= class_name %>MailerTest < Test::Unit::TestCase

  def setup
    @<%= singular_name %> = <%= class_name %>.new(:email => "homer@simpsons.com", :login => "homer", :activation_code => "12345")
    @mailer_params = { :from      => "info@mysite.com",
                       :to        => @<%= singular_name %>.email,
                       :subject   => "Welcome to MySite.com" }
  end
  
  def tear_down
    Merb::Mailer.deliveries.clear
  end
  
  def test_signup_email_goes_to_the_right_place
    deliver(:signup_notification, @mailer_params, :<%= singular_name %> => @<%= singular_name %>)
    assert @delivery.assigns(:headers).any? {|v| v == "to: homer@simpsons.com"} 
  end

  def test_signup_email_should_come_from_the_right_place
    deliver(:signup_notification, @mailer_params, :<%= singular_name %> => @<%= singular_name %>)
    assert @delivery.assigns(:headers).any? {|v| v == "from: info@mysite.com"} 
  end
  
  def test_signup_email_should_mention_the_login_name
    deliver(:signup_notification, @mailer_params, :<%= singular_name %> => @<%= singular_name %>)
    assert_match %r(#{@<%= singular_name %>.login}), @delivery.text
  end

  def test_signup_html_email_should_mention_the_login_name
    deliver(:signup_notification, @mailer_params, :<%= singular_name %> => @<%= singular_name %>)
    assert_match %r(#{@<%= singular_name %>.login}), @delivery.html
  end

  def test_signup_email_should_mention_the_activation_link
    deliver(:signup_notification, @mailer_params, :<%= singular_name %> => @<%= singular_name %>)
    assert_match %r(#{@<%= singular_name %>.activation_code}), @delivery.text
    assert_match %r(#{@<%= singular_name %>.activation_code}), @delivery.html
  end

  def test_activation_email_should_go_to_the_right_place
    deliver(:activation_notification, @mailer_params, :<%= singular_name %> => @<%= singular_name %>)
    assert @delivery.assigns(:headers).any?{|v| v == "to: homer@simpsons.com"}
  end

  def test_activation_email_should_come_from_the_right_place
    deliver(:activation_notification, @mailer_params, :<%= singular_name %> => @<%= singular_name %>)
    assert @delivery.assigns(:headers).any?{|v| v == "from: info@mysite.com"}
  end
  
  def test_should_mention_the_login_in_the_activation_email
    deliver(:activation_notification, @mailer_params, :<%= singular_name %> => @<%= singular_name %>)
    assert_match %r(#{@<%= singular_name %>.login}), @delivery.text
    assert_match %r(#{@<%= singular_name %>.login}), @delivery.html
  end
  private
  def deliver(action, mail_opts= {},opts = {})
    <%= class_name %>Mailer.dispatch_and_deliver action, mail_opts, opts
    @delivery = Merb::Mailer.deliveries.last
  end

end