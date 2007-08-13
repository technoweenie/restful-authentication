class <%= model_controller_class_name %>Controller < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
  end

  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
    @<%= file_name %>.save!
    self.current_<%= file_name %> = @<%= file_name %>
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
<% if options[:include_activation] %>
  def activate
    self.current_<%= file_name %> = <%= class_name %>.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_<%= file_name %>.activated?
      current_<%= file_name %>.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
<% end %>
end
