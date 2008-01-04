class <%= model_controller_class_name %> < Application
  provides :xml
  include AuthenticatedSystem::Controller
  
  skip_before :login_required
  
  def new(<%= singular_name %> = {})
    only_provides :html
    @<%= singular_name %> = <%= class_name %>.new(<%= singular_name %>)
    render @<%= singular_name %>
  end
  
  def create(<%= singular_name %>)
    cookies.delete :auth_token
    
    @<%= singular_name %> = <%= class_name %>.new(<%= singular_name %>)
    if @<%= singular_name %>.save
      redirect_back_or_default('/')
    else
      render :action => :new
    end
  end
  
<% if include_activation -%>
  def activate(activation_code)
    self.current_<%= singular_name %> = <%= class_name %>.find_activated_authenticated_model(activation_code)
    if logged_in? && !current_<%= singular_name %>.active?
      current_<%= singular_name %>.activate
    end
    redirect_back_or_default('/')
  end
<% end -%>
end