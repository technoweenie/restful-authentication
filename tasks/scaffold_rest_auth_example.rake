#!/usr/bin/env ruby
require 'rubygems'
require 'fileutils'; include FileUtils::Verbose

APP_BASE_DIR            = '/tmp'
APP_NAME                = 'empty_app'
APP_DIR                 = File.join(APP_BASE_DIR, APP_NAME)
PLUGIN_BASE_DIR         = File.expand_path('~/ics/plugins/rails/')
PLUGIN_DIRS             = {              # note: _ only in target names
  :restful_authentication  => File.join(PLUGIN_BASE_DIR, 'mainline_restful_authentication'),
  :rspec                   => File.join(PLUGIN_BASE_DIR, 'rspec'),
  :rspec_rails             => File.join(PLUGIN_BASE_DIR, 'rspec_rails'),
  :aasm                    => File.join(PLUGIN_BASE_DIR, 'aasm'),
}


#
# Steps
#
task :default => ['fubar:empty_app', 'fubar:plugins:link', 'fubar:generate:all', 'fubar:db:migrate', 'fubar:spec']

namespace :fubar do
  directory APP_BASE_DIR
  desc "Scaffolds the basic, empty app"
  file APP_DIR => [APP_BASE_DIR] do |t|
    cd APP_BASE_DIR do
      sh %{ rails --force #{APP_NAME} }
    end
  end
  task :empty_app => APP_DIR

  namespace :plugins do
    desc "Link to required plugins"
    task :all
    PLUGIN_DIRS.each do |plugin, src_dir|
      dest_dir = File.join(APP_DIR, "vendor", "plugins", plugin.to_s)
      file dest_dir do |t|
        cd APP_DIR do
          rm_f dest_dir
          ln_s src_dir, dest_dir
        end
      end
      desc "Link to the #{plugin} plugin"
      task "link_#{plugin}" => dest_dir
      task :all             => "plugins:link_#{plugin}"
    end
  end

  # if generators fail as 'not found', try
  # http://github.com/rails/rails/commit/f90eb81c65d5841b591caf0f5e39ef774d02d06e
  # -- it's because rails <= 2.1.0 hates symlinked plugin dirs.
  namespace :generate do
    desc "Run scaffold generators"
    task :all

    require 'activesupport'
    allargs = [:skip_migration, :include_activation, :stateful, :aasm, :rspec, :no_rspec, :skip_routes, :old_passwords, :dump_generator_attrs, ]

    # generator        models   flags     helpers
    generators = [
      [:rspec,         '',      [],        [],                    ],
      [:authenticated, 'User',  [:rspec,], ['sessions', 'users'], ],
    ]

    generators.each do |generator, models, flags, helpers|
      task :all => generator
      argstrs = flags.map{|a| '--'+a.to_s.dasherize}.join(' ')
      task generator => ['plugins:all'] do
        cd APP_DIR do
          helpers.each do |helper| rm_f "app/helpers/#{helper}_helper.rb" end
          sh %{ ./script/generate #{generator} #{models} #{argstrs} }
        end
      end
      namespace :destroy do
        task generator do
          cd APP_DIR do sh %{ ./script/destroy #{generator} #{models} #{argstrs} } end
        end
        task :all => generator
      end
    end

  end

  namespace :db do
    task :migrate => ['generate:all'] do
      cd APP_DIR do sh %{ rake db:migrate:reset } end
    end
  end

  task :spec => ['db:migrate'] do
    cd APP_DIR do sh %{ rake spec } end
  end

  # generate rspec
  # rake db:migrate
  # rake spec
end
