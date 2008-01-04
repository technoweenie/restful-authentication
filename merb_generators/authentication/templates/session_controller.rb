require 'lib/authenticated_system_controller'
class <%= controller_class_name %> < Application

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem::Controller
  
  skip_before :login_required
  
  def new
    render
  end

  def create(login = "", password = "")
    self.current_<%= singular_name %> = <%= class_name %>.authenticate(login, password)
    if logged_in?
      if params[:remember_me] == "1"
        self.current_<%= singular_name %>.remember_me
        cookies[:auth_token] = { :value => self.current_<%= singular_name %>.remember_token , :expires => self.current_<%= singular_name %>.remember_token_expires_at }
      end
      redirect_back_or_default('/')
    else
      render :action => "new"
    end
  end

  def destroy
    self.current_<%= singular_name %>.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_back_or_default('/')
  end
  
end