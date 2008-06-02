module AuthenticationTestHelper

  # Sets the current <%= model_name %> in the session from the given <%= model_name %>
  def login_as(<%= model_name %>)
    @request.session[:user_id] = <%= model_name %> ? <%= fixtures_name %>(<%= model_name %>).id : nil
  end

  # Fakes login by HTTP basic (or prevents it, with <%= model_name %>==nil)
  def authorize_as(<%= model_name %>)
    @request.env["HTTP_AUTHORIZATION"] = <%= model_name %> ? ActionController::HttpAuthentication::Basic.encode_credentials(<%= fixtures_name %>(<%= model_name %>).login, 'monkey') : nil
  end

  def new_<%= model_name %>_params
    {
      :login => 'quire',
      :email => 'quire@example.com',
      :name  => 'Preachen Quire II',
      :password => 'quire69', :password_confirmation => 'quire69',
    }
  end
  # for model testing
  def create_<%= model_name %>(options = {})
    record = <%= class_name %>.new(new_<%= model_name %>_params.merge(options))
    record.save
    record
  end

<% if options[:rspec] %>
  # mock model for isolation testing
  def mock_<%= model_name %>(options = {})
    options.reverse_merge! :errors  => [],
      :to_xml  => "<%= class_name %>-in-XML",
      :to_json => "<%= class_name %>-in-JSON"
    <%= model_name %> = mock_model(<%= class_name %>, options)
  end

  # convenience method for validation specs
  def is_not_valid_and_does_not_save obj
    obj.should_not        be_valid
    obj.save.should       be_false
    obj.errors.should_not be_empty
  end
  def is_valid_and_saves obj, attrs=[]
    obj.should            be_valid
    obj.save.should_not   be_false
    obj.errors.should     be_empty
    attrs.each do |attr, val|
      obj[attr].should == val
    end
  end

  # test modules in isolation by faking a barebones controller
  def mock_authentication_controller
    # set up module rig
    mock_controller_class = Class.new do
      stub!(:rescue_from)
      include Authentication, AccessControl, SecurityPolicy
    end
    # Fake a controller
    mock_controller = mock_controller_class.new
    mock_controller.stub!(:session).and_return( {} )
    mock_controller.stub!(:reset_session)
    [mock_controller, mock_controller_class]
  end

  def stub_auth!(ctrlr, val)
    ctrlr.stub!(:get_authorization).and_return(val)
  end
  <% end %>
end
