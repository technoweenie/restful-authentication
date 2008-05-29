Visitors should be in control of creating an account and of proving their
essential humanity/accountability or whatever it is people think the
id-validation does.  We should be fairly skeptical about this process, as the
identity+trust chain starts here.

Story: Creating an account
  As an anonymous <%= file_name %>
  I want to be able to create an account
  So that I can be one of the cool kids

  #
  # Account Creation: Get entry form
  #
  Scenario: Anonymous <%= file_name %> can start creating an account
    Given an anonymous <%= file_name %>
    When  she goes to /signup
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  the page should look AWESOME
     And  she should see a <form> containing a textfield: Login, textfield: Email, password: Password, password: 'Confirm Password', submit: 'Sign up'

  #
  # Account Creation
  #
  Scenario: Anonymous <%= file_name %> can create an account
    Given an anonymous <%= file_name %>
     And  no <%= file_name %> with login: 'Oona' exists
    When  she registers an account as the preloaded 'Oona'
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Thanks for signing up!'
     And  a <%= file_name %> with login: 'oona' should exist
     And  the <%= file_name %> should have login: 'oona', and email: 'unactivated@example.com'
<% if options[:include_activation] %>
     And  the <%= file_name %>'s activation_code should not be nil
     And  the <%= file_name %>'s activated_at    should     be nil
     And  she should not be logged in
<% else %>
     And  oona should be logged in
<% end %>

  #
  # Account Creation Failure: Account exists
  #
<% if options[:include_activation] %>
  Scenario: Anonymous <%= file_name %> can not create an account replacing a non-activated account
    Given an anonymous <%= file_name %>
     And  a registered <%= file_name %> named 'Reggie'
     And  the <%= file_name %> has activation_code: 'activate_me', activated_at: nil! 
     And  we try hard to remember the <%= file_name %>'s updated_at, and created_at
    When  she registers an account with login: 'reggie', password: 'monkey', and email: 'different@example.com'
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  she should     see an errorExplanation message 'Login has already been taken'
     And  she should not see an errorExplanation message 'Email has already been taken'
     And  a <%= file_name %> with login: 'reggie' should exist
     And  the <%= file_name %> should have email: 'registered@example.com'
     And  the <%= file_name %>'s activation_code should not be nil
     And  the <%= file_name %>'s activated_at    should     be nil
     And  the <%= file_name %>'s created_at should stay the same under to_s
     And  the <%= file_name %>'s updated_at should stay the same under to_s
     And  she should not be logged in<% end %>
     
  Scenario: Anonymous <%= file_name %> can not create an account replacing an activated account
    Given an anonymous <%= file_name %>
     And  an activated <%= file_name %> named 'Reggie'
     And  we try hard to remember the <%= file_name %>'s updated_at, and created_at
    When  she registers an account with login: 'reggie', password: 'monkey', and email: 'reggie@example.com'
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  she should     see an errorExplanation message 'Login has already been taken'
     And  she should not see an errorExplanation message 'Email has already been taken'
     And  a <%= file_name %> with login: 'reggie' should exist
     And  the <%= file_name %> should have email: 'registered@example.com'
<% if options[:include_activation] %>
     And  the <%= file_name %>'s activation_code should     be nil
     And  the <%= file_name %>'s activated_at    should not be nil<% end %>
     And  the <%= file_name %>'s created_at should stay the same under to_s
     And  the <%= file_name %>'s updated_at should stay the same under to_s
     And  she should not be logged in

  #
  # Account Creation Failure: Incomplete input
  #
  Scenario: Anonymous <%= file_name %> can not create an account with incomplete or incorrect input
    Given an anonymous <%= file_name %>
     And  no <%= file_name %> with login: 'Oona' exists
    When  she registers an account with login: '',     password: 'monkey', password_confirmation: 'monkey' and email: 'unactivated@example.com'
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  she should     see an errorExplanation message 'Login can't be blank'
     And  no <%= file_name %> with login: 'oona' should exist
     
  Scenario: Anonymous <%= file_name %> can not create an account with no password
    Given an anonymous <%= file_name %>
     And  no <%= file_name %> with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: '',       password_confirmation: 'monkey' and email: 'unactivated@example.com'
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  she should     see an errorExplanation message 'Password can't be blank'
     And  no <%= file_name %> with login: 'oona' should exist
     
  Scenario: Anonymous <%= file_name %> can not create an account with no password_confirmation
    Given an anonymous <%= file_name %>
     And  no <%= file_name %> with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: ''       and email: 'unactivated@example.com'
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  she should     see an errorExplanation message 'Password confirmation can't be blank'
     And  no <%= file_name %> with login: 'oona' should exist
     
  Scenario: Anonymous <%= file_name %> can not create an account with mismatched password & password_confirmation
    Given an anonymous <%= file_name %>
     And  no <%= file_name %> with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: 'monkeY' and email: 'unactivated@example.com'
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  she should     see an errorExplanation message 'Password doesn't match confirmation'
     And  no <%= file_name %> with login: 'oona' should exist
     
  Scenario: Anonymous <%= file_name %> can not create an account with bad email
    Given an anonymous <%= file_name %>
     And  no <%= file_name %> with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: 'monkey' and email: ''
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  she should     see an errorExplanation message 'Email can't be blank'
     And  no <%= file_name %> with login: 'oona' should exist
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: 'monkey' and email: 'unactivated@example.com'
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Thanks for signing up!'
     And  a <%= file_name %> with login: 'oona' should exist
     And  the <%= file_name %> should have login: 'oona', and email: 'unactivated@example.com'
<% if options[:include_activation] %>
     And  the <%= file_name %>'s activation_code should not be nil
     And  the <%= file_name %>'s activated_at    should     be nil
     And  she should not be logged in
<% else %>
     And  oona should be logged in
<% end %>
     
<% if options[:include_activation] %>
Story: Activating an account
  As a registered, but not yet activated, <%= file_name %>
  I want to be able to activate my account
  So that I can log in to the site

  #
  # Successful activation
  #
  Scenario: Not-yet-activated <%= file_name %> can activate her account
    Given a registered <%= file_name %> named 'Reggie'
     And  the <%= file_name %> has activation_code: 'activate_me', activated_at: nil! 
     And  we try hard to remember the <%= file_name %>'s updated_at, and created_at
    When  she goes to /activate/activate_me
    Then  she should be redirected to 'login'
    When  she follows that redirect!
    Then  she should see a notice message 'Signup complete!'
     And  a <%= file_name %> with login: 'reggie' should exist
     And  the <%= file_name %> should have login: 'reggie', and email: 'registered@example.com'
     And  the <%= file_name %>'s activation_code should     be nil
     And  the <%= file_name %>'s activated_at    should not be nil
     And  she should not be logged in

  #
  # Unsuccessful activation
  #
  Scenario: Not-yet-activated <%= file_name %> can't activate her account with a blank activation code
    Given a registered <%= file_name %> named 'Reggie'
     And  the <%= file_name %> has activation_code: 'activate_me', activated_at: nil! 
     And  we try hard to remember the <%= file_name %>'s updated_at, and created_at
    When  she goes to /activate/
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see an error  message 'activation code was missing'
     And  a <%= file_name %> with login: 'reggie' should exist
     And  the <%= file_name %> should have login: 'reggie', activation_code: 'activate_me', and activated_at: nil!
     And  the <%= file_name %>'s updated_at should stay the same under to_s
     And  she should not be logged in
  
  Scenario: Not-yet-activated <%= file_name %> can't activate her account with a bogus activation code
    Given a registered <%= file_name %> named 'Reggie'
     And  the <%= file_name %> has activation_code: 'activate_me', activated_at: nil! 
     And  we try hard to remember the <%= file_name %>'s updated_at, and created_at
    When  she goes to /activate/i_haxxor_joo
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see an error  message 'couldn\'t find a <%= file_name %> with that activation code'
     And  a <%= file_name %> with login: 'reggie' should exist
     And  the <%= file_name %> should have login: 'reggie', activation_code: 'activate_me', and activated_at: nil!
     And  the <%= file_name %>'s updated_at should stay the same under to_s
     And  she should not be logged in
<% end %>
