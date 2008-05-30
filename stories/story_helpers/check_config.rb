#
# # for the stories to pass, you need to have these paths set
# [
#   [route_for(:controller => 'session', :action => 'new'),     "/login"],
#   [route_for(:controller => 'session', :action => 'destroy'), "/logout"],
#   [route_for(:controller => 'users',   :action => 'new'),     "/signup"],
# ].each do |actual, desired|
#   raise "You need to set the named route #{desired} for the restful_authentication stories to run -- see README"
# end
#
# And you need to include the module
# raise 'Please add "include AuthenticationController" to your ApplicationController' unless ApplicationController.respond_to? 'current_user'
