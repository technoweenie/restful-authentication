# If you have a global stories helper, move this line there:
include AuthenticationTestHelper
this_dir = File.dirname(__FILE__)

# Make visible for testing
ApplicationController.send(:public, :logged_in?, :current_user, :authorized?)

# add helper modules
Dir[this_dir+"/story_helpers/*.rb"].each do |file|
  require file
end

# steps
Dir[this_dir+"/steps/*.rb"].each do |file|
  puts "require #{file}"
  require file
end

