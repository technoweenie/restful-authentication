Story: Activating an account
  As a registered, but not yet activated, user
  I want to be able to activate my account
  So that I can log in to the site

  #
  # Successful activation
  #
  Scenario: Not-yet-activated user can activate her account
    Given a registered user named 'Reggie'
     And  the user has activation_code: 'activate_me', activated_at: nil! 
     And  we try hard to remember the user's updated_at, and created_at
    When  she goes to /activate/activate_me
    Then  she should be redirected to 'session/new'
    When  she follows that redirect!
    Then  she should see a notice message 'Signup complete!'
     And  a user with login: 'reggie' should exist
     And  the user should have login: 'reggie', and email: 'registered@example.com'
     And  the user's activation_code should     be nil
     And  the user's activated_at    should not be nil
     And  she should not be logged in

  #
  # Unsuccessful activation
  #
  Scenario: Not-yet-activated user can't activate her account with a blank activation code
    Given a registered user named 'Reggie'
     And  the user has activation_code: 'activate_me', activated_at: nil! 
     And  we try hard to remember the user's updated_at, and created_at
    When  she goes to /activate/
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see an error  message 'activation code was missing'
     And  a user with login: 'reggie' should exist
     And  the user should have login: 'reggie', activation_code: 'activate_me', and activated_at: nil!
     And  the user's updated_at should stay the same under to_s
     And  she should not be logged in
  
  Scenario: Not-yet-activated user can't activate her account with a bogus activation code
    Given a registered user named 'Reggie'
     And  the user has activation_code: 'activate_me', activated_at: nil! 
     And  we try hard to remember the user's updated_at, and created_at
    When  she goes to /activate/i_haxxor_joo
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see an error  message 'couldn\'t find a user with that activation code'
     And  a user with login: 'reggie' should exist
     And  the user should have login: 'reggie', activation_code: 'activate_me', and activated_at: nil!
     And  the user's updated_at should stay the same under to_s
     And  she should not be logged in
