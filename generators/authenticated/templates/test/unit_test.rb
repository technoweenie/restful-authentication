require File.dirname(__FILE__) + '/../test_helper'

class <%= class_name %>Test < Test::Unit::TestCase
  fixtures :<%= fixtures_name %>

  def test_should_create_<%= model_name %>
    assert_difference '<%= class_name %>.count' do
      <%= model_name %> = create_<%= model_name %>
      assert !<%= model_name %>.new_record?, "#{<%= model_name %>.errors.full_messages.to_sentence}"
    end
  end
<% if options[:include_activation] %>
  def test_should_initialize_activation_code_upon_creation
    <%= model_name %> = create_<%= model_name %>
    <%= model_name %>.reload
    assert_not_nil <%= model_name %>.activation_code
  end
<% end %><% if options[:stateful] %>
  def test_should_create_and_start_in_pending_state
    <%= model_name %> = create_<%= model_name %>
    <%= model_name %>.reload
    assert <%= model_name %>.pending?
  end

<% end %>
  def test_should_require_login
    assert_no_difference '<%= class_name %>.count' do
      u = create_<%= model_name %>(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference '<%= class_name %>.count' do
      u = create_<%= model_name %>(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference '<%= class_name %>.count' do
      u = create_<%= model_name %>(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference '<%= class_name %>.count' do
      u = create_<%= model_name %>(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    <%= fixtures_name %>(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal <%= fixtures_name %>(:quentin), <%= class_name %>.authenticate_by_password('quentin', 'new password')
  end

  def test_should_not_rehash_password
    <%= fixtures_name %>(:quentin).update_attributes(:login => 'quentin2')
    assert_equal <%= fixtures_name %>(:quentin), <%= class_name %>.authenticate_by_password('quentin2', 'monkey')
  end

  def test_should_authenticate_<%= model_name %>
    assert_equal <%= fixtures_name %>(:quentin), <%= class_name %>.authenticate_by_password('quentin', 'monkey')
  end

  def test_should_set_remember_token
    <%= fixtures_name %>(:quentin).remember_me
    assert_not_nil <%= fixtures_name %>(:quentin).remember_token
    assert_not_nil <%= fixtures_name %>(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    <%= fixtures_name %>(:quentin).remember_me
    assert_not_nil <%= fixtures_name %>(:quentin).remember_token
    <%= fixtures_name %>(:quentin).forget_me
    assert_nil <%= fixtures_name %>(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    <%= fixtures_name %>(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil <%= fixtures_name %>(:quentin).remember_token
    assert_not_nil <%= fixtures_name %>(:quentin).remember_token_expires_at
    assert <%= fixtures_name %>(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    <%= fixtures_name %>(:quentin).remember_me_until time
    assert_not_nil <%= fixtures_name %>(:quentin).remember_token
    assert_not_nil <%= fixtures_name %>(:quentin).remember_token_expires_at
    assert_equal <%= fixtures_name %>(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    <%= fixtures_name %>(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil <%= fixtures_name %>(:quentin).remember_token
    assert_not_nil <%= fixtures_name %>(:quentin).remember_token_expires_at
    assert <%= fixtures_name %>(:quentin).remember_token_expires_at.between?(before, after)
  end

protected
  def create_<%= model_name %>(options = {})
    record = <%= class_name %>.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.<% if options[:stateful] %>register! if record.valid?<% else %>save<% end %>
    record
  end
end
