require File.dirname(__FILE__) + '/../helper'

RE_<%= file_name.capitalize %>      = %r{(?:(?:the )? *(\w+) *)}
RE_<%= file_name.capitalize %>_TYPE = %r{(?: *(\w+)? *)}
steps_for(:<%= file_name %>) do

  #
  # Setting
  #
  
  Given "an anonymous <%= file_name %>" do 
    log_out!
  end

  Given "$an $<%= file_name %>_type <%= file_name %> with $attributes" do |_, <%= file_name %>_type, attributes|
    create_<%= file_name %>! <%= file_name %>_type, attributes.to_hash_from_story
  end
  
  Given "$an $<%= file_name %>_type <%= file_name %> named '$login'" do |_, <%= file_name %>_type, login|
    create_<%= file_name %>! <%= file_name %>_type, named_<%= file_name %>(login)
  end
  
  Given "$an $<%= file_name %>_type <%= file_name %> logged in as '$login'" do |_, <%= file_name %>_type, login|
    create_<%= file_name %>! <%= file_name %>_type, named_<%= file_name %>(login)
    log_in_<%= file_name %>!
  end
  
  Given "$actor is logged in" do |_, login|
    log_in_<%= file_name %>! @<%= file_name %>_params || named_<%= file_name %>(login)
  end
  
  Given "there is no $<%= file_name %>_type <%= file_name %> named '$login'" do |_, login|
    @<%= file_name %> = <%= class_name %>.find_by_login(login)
    @<%= file_name %>.destroy! if @<%= file_name %>
    @<%= file_name %>.should be_nil
  end
  
  #
  # Actions
  #
  When "$actor logs out" do 
    log_out
  end

  When "$actor registers an account as the preloaded '$login'" do |_, login|
    <%= file_name %> = named_<%= file_name %>(login)
    <%= file_name %>['password_confirmation'] = <%= file_name %>['password']
    create_<%= file_name %> <%= file_name %>
  end

  When "$actor registers an account with $attributes" do |_, attributes|
    create_<%= file_name %> attributes.to_hash_from_story
  end
<% if options[:include_activation] %>  
  When "$actor activates with activation code $attributes" do |_, activation_code|
    activation_code = '' if activation_code == 'that is blank'
    activate 
  end<% end %>  

  When "$actor logs in with $attributes" do |_, attributes|
    log_in_<%= file_name %> attributes.to_hash_from_story
  end
  
  #
  # Result
  #
  Then "$actor should be invited to sign in" do |_|
    response.should render_template('/<%= controller_file_path %>/new')
  end
  
  Then "$actor should not be logged in" do |_|
    controller.logged_in?.should_not be_true
  end
    
  Then "$login should be logged in" do |login|
    controller.logged_in?.should be_true
    controller.current_<%= file_name %>.should === @<%= file_name %>
    controller.current_<%= file_name %>.login.should == login
  end
    
end

def named_<%= file_name %> login
  <%= file_name %>_params = {
    'admin'   => {'id' => 1, 'login' => 'addie', 'password' => '1234addie', 'email' => 'admin@example.com',       },
    'oona'    => {          'login' => 'oona',   'password' => '1234oona',  'email' => 'unactivated@example.com'},
    'reggie'  => {          'login' => 'reggie', 'password' => 'monkey',    'email' => 'registered@example.com' },
    }
  <%= file_name %>_params[login.downcase]
end

#
# <%= class_name %> account actions.
#
# The ! methods are 'just get the job done'.  It's true, they do some testing of
# their own -- thus un-DRY'ing tests that do and should live in the <%= file_name %> account
# stories -- but the repetition is ultimately important so that a faulty test setup
# fails early.  
#

def log_out 
  get '/<%= controller_file_path %>/destroy'
end

def log_out!
  log_out
  response.should redirect_to('/')
  follow_redirect!
end

def create_<%= file_name %>(<%= file_name %>_params={})
  @<%= file_name %>_params       ||= <%= file_name %>_params
  post "/<%= model_controller_file_path %>", :<%= file_name %> => <%= file_name %>_params
  @<%= file_name %> = <%= class_name %>.find_by_login(<%= file_name %>_params['login'])
end

def create_<%= file_name %>!(<%= file_name %>_type, <%= file_name %>_params)
  <%= file_name %>_params['password_confirmation'] ||= <%= file_name %>_params['password'] ||= <%= file_name %>_params['password']
  create_<%= file_name %> <%= file_name %>_params
  response.should redirect_to('/')
  follow_redirect!
<% if options[:include_activation] %> 
  # fix the <%= file_name %>'s activation status
  activate_<%= file_name %>! if <%= file_name %>_type == 'activated'<% end %>
end

<% if options[:include_activation] %> 
def activate_<%= file_name %> activation_code=nil
  activation_code = @<%= file_name %>.activation_code if activation_code.nil?
  get "/activate/#{activation_code}"
end

def activate_<%= file_name %>! *args
  activate_<%= file_name %> *args
  response.should redirect_to('/login')
  follow_redirect!
  response.should have_flash("notice", /Signup complete!/)
end<% end %>

def log_in_<%= file_name %> <%= file_name %>_params=nil
  @<%= file_name %>_params ||= <%= file_name %>_params
  <%= file_name %>_params  ||= @<%= file_name %>_params
  post "/<%= controller_routing_path %>", <%= file_name %>_params
  @<%= file_name %> = <%= class_name %>.find_by_login(<%= file_name %>_params['login'])
  controller.current_<%= file_name %>
end

def log_in_<%= file_name %>! *args
  log_in_<%= file_name %> *args
  response.should redirect_to('/')
  follow_redirect!
  response.should have_flash("notice", /Logged in successfully/)
end
