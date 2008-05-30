#!/usr/bin/env ruby

# Standard story rig setup
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails/story_adapter'
require 'spec/story'
this_dir = File.dirname(__FILE__)

#
# module-specific setup
#

# $REST_AUTH_DIR defined in restful-authentication/init.rb
require File.join($REST_AUTH_DIR, 'stories', "rest_auth_stories_helper.rb")

# Decouple users steps from whatever we've named the <%= class_name %> class
def find_user_by_login(login) <%= class_name %>.find_by_login(login) end

#
# do this thing
#
step_components = [:ra_navigation, :ra_response, :ra_resource, :user]
story_files     = Dir[File.join($REST_AUTH_DIR, 'stories', "users", '*.story')]
with_steps_for *step_components do
  story_files.each do |file|
    run file, :type => RailsStory
  end
end
