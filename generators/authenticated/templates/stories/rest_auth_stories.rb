#!/usr/bin/env ruby
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails/story_adapter'
require 'spec/story'
require File.expand_path(File.dirname(__FILE__) + "/rest_auth_stories_helper.rb")

# Make visible for testing
ApplicationController.send(:public, :logged_in?, :current_user, :authorized?)

this_dir = File.dirname(__FILE__)
Dir[File.join(this_dir, "steps/*.rb")].each do |file|
  puts file.to_s
  require file
end

with_steps_for :ra_navigation, :ra_response, :ra_resource, :<%= file_name %> do
  story_files = Dir[File.join(this_dir, "<%= table_name %>", '*.story')]
  story_files.each do |file|
    run file, :type => RailsStory 
  end
end
