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
    @user = User.new
  end

  def create
    logout_keeping_session! 
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
    @user && @user.save()
    success = @<%= file_name %> && @<%= file_name %>.<% if options[:stateful] %>register! if @<%= file_name %>.valid?<% else %>save<% end %>
    if success && @<%= file_name %>.errors.empty?
      <% if !options[:include_activation] -%>
      # protects against session fixation attacks, wreaks havoc with 
      # request forgery protection.
      # reset_session
      self.current_<%= file_name %> = @<%= file_name %> # !! now logged in
      <% end -%>
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      @user.password = @user.password_confirmation = ''
      render :action => 'new'
    end
  end
<% if options[:include_activation] %>
  def activate
    self.current_<%= file_name %> = params[:activation_code].blank? ? false : <%= class_name %>.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_<%= file_name %>.active?
      current_<%= file_name %>.activate<% if options[:stateful] %>!<% end %>
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
<% end %><% if options[:stateful] %>
  def suspend
    @<%= file_name %>.suspend! 
    redirect_to <%= table_name %>_path
  end

  def unsuspend
    @<%= file_name %>.unsuspend! 
    redirect_to <%= table_name %>_path
  end

  def destroy
    @<%= file_name %>.delete!
    redirect_to <%= table_name %>_path
  end

  def purge
    @<%= file_name %>.destroy
    redirect_to <%= table_name %>_path
  end

protected
  def find_<%= file_name %>
    @<%= file_name %> = <%= class_name %>.find(params[:id])
  end
<% end %>
end
