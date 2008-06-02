%w[
  security_components
].each do |f|
  require f
end

# make it so we can find stories dir.
# FIXME -- this is crap
require 'pathname'
$REST_AUTH_DIR = Pathname.new(File.dirname(__FILE__)).realpath
