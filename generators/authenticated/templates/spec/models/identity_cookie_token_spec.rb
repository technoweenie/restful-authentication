require File.dirname(__FILE__) + '<%= ('/..'*model_controller_class_nesting_depth) + '/../spec_helper' %>'

describe Identity::CookieToken do
  before(:each) do
    # set up module rig
    @mock_model_class = Class.new do
      include Identity, Identity::CookieToken
    end
    @<%= model_name %> = @mock_model_class.new
  end

  #
  # remember_token?
  #
  describe "remember_token?" do
    before(:all) do
      @future = 5.minutes.from_now.utc
      @past   = 5.minutes.ago.utc
    end
    def set_remember_token token, expiry
      @<%= model_name %>.stub!(:remember_token).and_return( token )
      @<%= model_name %>.stub!(:remember_token_expires_at).and_return( expiry )
    end
    it "is true for valid, unexpired token" do set_remember_token 'valid_token', @future; @<%= model_name %>.should     be_remember_token end
    it "is false for remember_token nil"    do set_remember_token nil, @future;           @<%= model_name %>.should_not be_remember_token end
    it "is false for remember_token ''"     do set_remember_token '',  @future;           @<%= model_name %>.should_not be_remember_token end
    it "is false for expired"               do set_remember_token 'valid_token', @past;   @<%= model_name %>.should_not be_remember_token end
    it "is false for unset"                 do set_remember_token 'valid_token', nil;     @<%= model_name %>.should_not be_remember_token end
  end

  #
  # Setting / Refreshing token
  #
  describe "remember_me_until" do
    it "makes a token" do
      @mock_model_class.should_receive(:make_token).and_return('valid_token')
      @<%= model_name %>.should_receive(:remember_token=).with('valid_token')
      @<%= model_name %>.should_receive(:remember_token_expires_at=).with('time')
      @<%= model_name %>.should_receive(:save).with(false).and_return('result')
      @<%= model_name %>.remember_me_until('time').should == 'result'
    end
  end
  describe "refresh_token" do
    it "refreshes valid token, keeping expiry" do
      @<%= model_name %>.should_receive(:remember_token?).and_return(true)
      @mock_model_class.should_receive(:make_token).and_return('valid_token')
      @<%= model_name %>.should_receive(:remember_token=).with('valid_token')
      @<%= model_name %>.should_not_receive(:remember_token_expires_at=)
      @<%= model_name %>.should_receive(:save).with(false).and_return('result')
      @<%= model_name %>.refresh_token.should == 'result'
    end
    it "does nothing for invalid token" do
      @<%= model_name %>.should_receive(:remember_token?).and_return(false)
      @mock_model_class.should_not_receive(:make_token)
      @<%= model_name %>.should_not_receive(:remember_token=)
      @<%= model_name %>.should_not_receive(:remember_token_expires_at=)
      (@<%= model_name %>.refresh_token||false).should be_false
    end
  end

  #
  # Forget me
  #
  describe "forget_me" do
    it "kills token" do
      @<%= model_name %>.should_receive(:remember_token_expires_at=).with(nil)
      @<%= model_name %>.should_receive(:remember_token=).with(nil)
      @<%= model_name %>.should_receive(:save).and_return('who_am_i')
      @<%= model_name %>.forget_me.should == 'who_am_i'
    end
  end
end

describe <%= class_name %> do
  #
  # Authentication
  #
  describe "From fixtures" do
    fixtures :<%= fixtures_name %>
    it 'sets remember token' do
      <%= fixtures_name %>(:quentin).remember_me
      <%= fixtures_name %>(:quentin).remember_token.should_not be_nil
      <%= fixtures_name %>(:quentin).remember_token_expires_at.should_not be_nil
    end

    it 'unsets remember token' do
      <%= fixtures_name %>(:quentin).remember_me
      <%= fixtures_name %>(:quentin).remember_token.should_not be_nil
      <%= fixtures_name %>(:quentin).forget_me
      <%= fixtures_name %>(:quentin).remember_token.should be_nil
    end

    it 'remembers me for one week' do
      before = 1.week.from_now.utc
      <%= fixtures_name %>(:quentin).remember_me_for 1.week
      after = 1.week.from_now.utc
      <%= fixtures_name %>(:quentin).remember_token.should_not be_nil
      <%= fixtures_name %>(:quentin).remember_token_expires_at.should_not be_nil
      <%= fixtures_name %>(:quentin).remember_token_expires_at.between?(before, after).should be_true
    end

    it 'remembers me until one week' do
      time = 1.week.from_now.utc
      <%= fixtures_name %>(:quentin).remember_me_until time
      <%= fixtures_name %>(:quentin).remember_token.should_not be_nil
      <%= fixtures_name %>(:quentin).remember_token_expires_at.should_not be_nil
      <%= fixtures_name %>(:quentin).remember_token_expires_at.should == time
    end

    it 'remembers me default two weeks' do
      before = 2.weeks.from_now.utc
      <%= fixtures_name %>(:quentin).remember_me
      after = 2.weeks.from_now.utc
      <%= fixtures_name %>(:quentin).remember_token.should_not be_nil
      <%= fixtures_name %>(:quentin).remember_token_expires_at.should_not be_nil
      <%= fixtures_name %>(:quentin).remember_token_expires_at.between?(before, after).should be_true
    end
  end
end
