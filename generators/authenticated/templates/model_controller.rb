class <%= model_controller_class_name %>Controller < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  <% if options[:stateful] %>
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_<%= file_name %>, :only => [:suspend, :unsuspend, :destroy, :purge]
  <% end %>

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
<% if options[:stateful] %>    raise ActiveRecord::RecordInvalid.new(@user) unless @user.valid?<% end %>
    @<%= file_name %>.<% if options[:stateful] %>register<% else %>save<% end %>!
    self.current_<%= file_name %> = @<%= file_name %>
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
<% if options[:include_activation] %>
  def activate
    self.current_<%= file_name %> = params[:activation_code].blank? ? :false : <%= class_name %>.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_<%= file_name %>.active?
      current_<%= file_name %>.activate<% if options[:stateful] %>!<% end %>
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
<% end %><% if options[:stateful] %>
  def suspend
    @user.suspend! 
    redirect_to users_url
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_url
  end

  def destroy
    @user.delete!
    redirect_to users_url
  end

  def purge
    @user.destroy
    redirect_to users_url
  end

protected
  def find_<%= file_name %>
    @<%= file_name %> = User.find(params[:id])
  end
<% end %>
end
