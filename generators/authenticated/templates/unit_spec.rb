require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe <%= class_name %> do
  fixtures :<%= table_name %>
  
  it 'creates <%= file_name %>' do
    lambda do
      <%= file_name %> = create_<%= file_name %>
      violated "#{<%= file_name %>.errors.full_messages.to_sentence}" if <%= file_name %>.new_record?
    end.should change(<%= class_name %>, :count).by(1)
  end

  it 'requires login' do
    lambda do
      u = create_<%= file_name %>(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(<%= class_name %>, :count)
  end

  it 'requires password' do
    lambda do
      u = create_<%= file_name %>(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(<%= class_name %>, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_<%= file_name %>(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(<%= class_name %>, :count)
  end

  it 'requires email' do
    lambda do
      u = create_<%= file_name %>(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(<%= class_name %>, :count)
  end

  it 'resets password' do
    <%= table_name %>(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    <%= class_name %>.authenticate('quentin', 'new password').should == <%= table_name %>(:quentin)
  end

  it 'does not rehash password' do
    <%= table_name %>(:quentin).update_attributes(:login => 'quentin2')
    <%= class_name %>.authenticate('quentin2', 'test').should == <%= table_name %>(:quentin)
  end

  it 'authenticates <%= file_name %>' do
    <%= class_name %>.authenticate('quentin', 'test').should == <%= table_name %>(:quentin)
  end

  it 'sets remember token' do
    <%= table_name %>(:quentin).remember_me
    <%= table_name %>(:quentin).remember_token.should_not be_nil
    <%= table_name %>(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    <%= table_name %>(:quentin).remember_me
    <%= table_name %>(:quentin).remember_token.should_not be_nil
    <%= table_name %>(:quentin).forget_me
    <%= table_name %>(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    <%= table_name %>(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    <%= table_name %>(:quentin).remember_token.should_not be_nil
    <%= table_name %>(:quentin).remember_token_expires_at.should_not be_nil
    <%= table_name %>(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    <%= table_name %>(:quentin).remember_me_until time
    <%= table_name %>(:quentin).remember_token.should_not be_nil
    <%= table_name %>(:quentin).remember_token_expires_at.should_not be_nil
    <%= table_name %>(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    <%= table_name %>(:quentin).remember_me
    after = 2.weeks.from_now.utc
    <%= table_name %>(:quentin).remember_token.should_not be_nil
    <%= table_name %>(:quentin).remember_token_expires_at.should_not be_nil
    <%= table_name %>(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end
<% if options[:stateful] %>
  it 'registers passive <%= file_name %>' do
    <%= file_name %> = create_<%= file_name %>(:password => nil, :password_confirmation => nil)
    <%= file_name %>.should be_passive
    <%= file_name %>.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    <%= file_name %>.register!
    <%= file_name %>.should be_pending
  end

  it 'suspends <%= file_name %>' do
    <%= table_name %>(:quentin).suspend!
    <%= table_name %>(:quentin).should be_suspended
  end

  it 'does not authenticate suspended <%= file_name %>' do
    <%= table_name %>(:quentin).suspend!
    <%= class_name %>.authenticate('quentin', 'test').should_not == <%= table_name %>(:quentin)
  end

  it 'unsuspends <%= file_name %>' do
    <%= table_name %>(:quentin).suspend!
    <%= table_name %>(:quentin).should be_suspended
    <%= table_name %>(:quentin).unsuspend!
    <%= table_name %>(:quentin).should be_active
  end

  it 'deletes <%= file_name %>' do
    <%= table_name %>(:quentin).deleted_at.should be_nil
    <%= table_name %>(:quentin).delete!
    <%= table_name %>(:quentin).deleted_at.should_not be_nil
    <%= table_name %>(:quentin).should be_deleted
  end
<% end %>
protected
  def create_<%= file_name %>(options = {})
    <%= class_name %>.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end
