steps_for(:user_activation) do

  #
  # Setting
  #

  #
  # Actions
  #

  When "$actor activates with activation code $attributes" do |_, activation_code|
    activation_code = '' if activation_code == 'that is blank'
    activate
  end

end

def activate_user activation_code=nil
  activation_code = @user.activation_code if activation_code.nil?
  get "/activate/#{activation_code}"
end

def activate_user! *args
  activate_user *args
  response.should redirect_to('/session/new')
  follow_redirect!
  response.should have_flash("notice", /Signup complete!/)
end
