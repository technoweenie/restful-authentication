class <%= model_controller_class_name %>Controller < ApplicationController

  # render new.rhtml
  def new
    @<%= model_name %> = <%= class_name %>.new
  end

  def create
    logout_keeping_session!
    @<%= model_name %> = <%= class_name %>.new(params[:<%= model_name %>])
    success = @<%= model_name %> && @<%= model_name %>.save
    if success && @<%= model_name %>.errors.empty?
      become_logged_in_as @<%= model_name %> # logs in if authorized, does nothing if not
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      @<%= model_name %>.password = ''
      @<%= model_name %>.password_confirmation = ''
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  # There's no page here to update or destroy a <%= model_name %>.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.
  #
  # And if you add restful formatted paths, make sure you filter your response:
  #   format.xml do
  #     render :xml => @user.toxml(:only => [:name, :email, :login])
  #   end

protected

end
