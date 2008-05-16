module AuthenticatedTestHelper
  # Sets the current <%= file_name %> in the session from the <%= file_name %> fixtures.
  def login_as(<%= file_name %>)
    @request.session[:<%= file_name %>_id] = <%= file_name %> ? <%= table_name %>(<%= file_name %>).id : nil
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end
  
<% if options[:include_activation] -%>
  # For tests that include a mailer
  def set_mailer_in_test
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
<% end -%>
  
<% if options[:rspec] -%>
  # rspec
  def mock_<%= file_name %>
    <%= file_name %> = mock_model(<%= class_name %>, :id => 1,
      :login  => 'user_name',
      :name   => 'U. Surname',
      :to_xml => "XML", :to_json => "JSON", 
      :errors => [])
    <%= file_name %>
  end  
<% end -%>

end
