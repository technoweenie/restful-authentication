# -*- coding: mule-utf-8 -*-
require File.dirname(__FILE__) + '<%= ('/..'*model_controller_class_nesting_depth) + '/../spec_helper' %>'

describe <%= class_name %> do
  def create_<%= model_name %>_forcing_confirmation options
    options[:password_confirmation] = options[:password] if options[:password]
    create_<%= model_name %> options
  end
  #
  # Validations
  #
  describe 'validates correctly:' do
    field_validity = {
      :password => {
        :valid => ['Andre The Giant (7\'4", 520 lb.)', '6_ltrs', "Iñtërnâtiônàlizætiøn", '1234567890_234567890_234567890_234567890',],
        :invalid => [nil, '', "5ltrs", '1234567890_234567890_234567890_234567890_',]},
    }
    field_validity.each do |attr, vals|
      vals[:valid].each do |val|
        it "valid for #{attr} = '#{val}'"   do
          @<%= model_name %> = create_<%= model_name %>_forcing_confirmation(attr => val);
          is_valid_and_saves @<%= model_name %>, (attr==:password ? [] : {attr => val})
        end
      end
      vals[:invalid].each do |val|
        it "invalid for #{attr} = '#{val}'" do
          @<%= model_name %> = create_<%= model_name %>_forcing_confirmation(attr => val);
          is_not_valid_and_does_not_save @<%= model_name %>
        end
      end
    end
  end

  #
  # Creating a <%= model_name %>
  #
  describe "creating a <%= model_name %>" do
    it "requires a password"                    do @<%= model_name %> = create_<%= model_name %>_forcing_confirmation(:password => nil); is_not_valid_and_does_not_save @<%= model_name %> end
    it "requires password matches confirmation" do @<%= model_name %> = create_<%= model_name %>(:password => 'monkey100'); is_not_valid_and_does_not_save @<%= model_name %> end

    describe "password handled correctly:" do
      before(:each) do @<%= model_name %> = <%= class_name %>.new(new_<%= model_controller_routing_path.singularize %>_params) end
      it "encrypts"                     do @<%= model_name %>.should_receive(:encrypt_password) end
      it "makes salt" do
        @token = 'hiya'
        <%= class_name %>.should_receive(:make_token).with().at_least(:once).and_return(@token)
        @<%= model_name %>.should_receive(:salt=).with(@token).at_least(:once)
      end
      after(:each)  do @<%= model_name %>.save end
    end
  end

  #
  # Authentication
  #
  describe "authenticate_by_password" do
    fixtures :<%= fixtures_name %>
    before(:each) do
      @<%= model_name %> = <%= fixtures_name %>(:quentin)
    end
    it 'authenticates <%= model_name %> with good password' do
      <%= class_name %>.authenticate_by_password('quentin', 'monkey').should == <%= fixtures_name %>(:quentin)
    end
    it "raises BadPassword error on bad password" do
      @<%= model_name %> = 'howdy'
      lambda{ @<%= model_name %> = <%= class_name %>.authenticate_by_password('quentin', 'i_haxxor_joo') }.should raise_error(BadPassword)
      @<%= model_name %>.should == 'howdy'
    end
    it "raises BadPassword error on blank password" do
      @<%= model_name %> = 'howdy';
      lambda{ @<%= model_name %> = <%= class_name %>.authenticate_by_password('quentin', '') }.should raise_error(BadPassword)
      @<%= model_name %>.should == 'howdy'
    end
    it "raises AccountNotFound error on bogus <%= model_name %>" do
      @<%= model_name %> = 'howdy';
      lambda{ @<%= model_name %> = <%= class_name %>.authenticate_by_password('random_q_hacker', 'monkey') }.should raise_error(AccountNotFound)
      @<%= model_name %>.should == 'howdy'
    end
  end

  #
  # Password encryption
  #
  describe "password" do
    fixtures :<%= fixtures_name %>
    before(:each) do
      @<%= model_name %> = <%= fixtures_name %>(:quentin)
    end
    if REST_AUTH_SITE_KEY.blank?
      # old-school passwords
      it "encryption is compatible with old-style password" do
        <%= class_name %>.authenticate_by_password('old_password_holder', 'test').should == <%= fixtures_name %>(:old_password_holder)
      end
    else
      it "encryption is not compatible with old-style password" do
        lambda{  <%= class_name %>.authenticate_by_password('old_password_holder', 'test') }.should raise_error(BadPassword)
      end

      it "encryption stretches the password" do
        <%= class_name %>.should_receive(:secure_digest).with(anything(), 'salt', 'plaintext', anything()).at_least(REST_AUTH_DIGEST_STRETCHES)
        <%= class_name %>.password_digest('plaintext', 'salt')
      end

      # New installs should bump this up and set REST_AUTH_DIGEST_STRETCHES to give a 10ms encrypt time or so
      desired_encryption_expensiveness_ms = 0.1
      it "encryption takes longer than #{desired_encryption_expensiveness_ms}ms to encrypt a password" do
        test_reps = 100
        start_time = Time.now; test_reps.times{ <%= class_name %>.authenticate_by_password('quentin', 'monkey') }; end_time   = Time.now
        auth_time_ms = 1000 * (end_time - start_time)/test_reps
        auth_time_ms.should > desired_encryption_expensiveness_ms
      end
      it "encryption doesn't make salt for old <%= model_name %>" do
        <%= class_name %>.should_not_receive(:make_token)
        @<%= model_name %>.should_not_receive(:salt=)
        @<%= model_name %>.send(:encrypt_password)
      end
      it "encrypts with salt"           do
        @<%= model_name %>.should_receive(:salt).at_least(:once).and_return('hiya');
        @<%= model_name %>.send(:encrypt, 'monkey69')
      end
      it 'can be set' do
        <%= fixtures_name %>(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
        <%= class_name %>.authenticate_by_password('quentin', 'new password').should == <%= fixtures_name %>(:quentin)
      end
      it 'is not rehashed unless password is changed' do
        @<%= model_name %>.update_attributes(:login => 'quentin2')
        <%= class_name %>.authenticate_by_password('quentin2', 'monkey').should == @<%= model_name %>
      end
      it "doesn't show on retrieval" do
        <%= class_name %>.find(1).password().should be_nil
      end
    end
  end
end
