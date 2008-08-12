require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe <%= class_name %> do
  fixtures :<%= table_name %>

  describe 'being created' do
    before do
      @<%= file_name %> = nil
      @creating_<%= file_name %> = lambda do
        @<%= file_name %> = create_<%= file_name %>
        violated "#{@<%= file_name %>.errors.full_messages.to_sentence}" if @<%= file_name %>.new_record?
      end
    end

    it 'starts in pending state' do
      @creating_<%= file_name %>.call
      @<%= file_name %>.reload
      @<%= file_name %>.should be_pending
    end
  end

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
    <%= class_name %>.authenticate('quentin', 'monkey').should_not == <%= table_name %>(:quentin)
  end

  it 'deletes <%= file_name %>' do
    <%= table_name %>(:quentin).deleted_at.should be_nil
    <%= table_name %>(:quentin).delete!
    <%= table_name %>(:quentin).deleted_at.should_not be_nil
    <%= table_name %>(:quentin).should be_deleted
  end

  describe "being unsuspended" do
    fixtures :<%= table_name %>

    before do
      @<%= file_name %> = <%= table_name %>(:quentin)
      @<%= file_name %>.suspend!
    end

    it 'reverts to active state' do
      @<%= file_name %>.unsuspend!
      @<%= file_name %>.should be_active
    end

    it 'reverts to passive state if activation_code and activated_at are nil' do
      <%= class_name %>.update_all :activation_code => nil, :activated_at => nil
      @<%= file_name %>.reload.unsuspend!
      @<%= file_name %>.should be_passive
    end

    it 'reverts to pending state if activation_code is set and activated_at is nil' do
      <%= class_name %>.update_all :activation_code => 'foo-bar', :activated_at => nil
      @<%= file_name %>.reload.unsuspend!
      @<%= file_name %>.should be_pending
    end
  end
protected
  def create_<%= file_name %>(options = {})
    record = <%= class_name %>.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.<% if options[:stateful] %>register! if record.valid?<% else %>save<% end %>
    record
  end
end
