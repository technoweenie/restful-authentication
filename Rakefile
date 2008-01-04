require 'rubygems'
require 'rake/gempackagetask'

PLUGIN = "merbful_authentication"
NAME = "merbful_authentication"
VERSION = "0.0.1"
AUTHOR = "Daniel Neighman"
EMAIL = "has.sox@gmail.com"
HOMEPAGE = "http://rubyforge.org/projects/merbful-auth/"
SUMMARY = "A Merb plugin that is essentially a port of Rick Olsons restful_authentication plugin for rails"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('merb', '>= 0.4.0')
  s.require_path = 'lib'
  s.autorequire = PLUGIN
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,specs,merb_generators,datamapper_generators,activerecord_generators,rspec_generators,test_unit_generators}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task :install => [:package] do
  sh %{sudo gem install pkg/#{NAME}-#{VERSION}}
end