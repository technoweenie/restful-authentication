REST_AUTH_DIR = File.dirname(__FILE__) unless defined? REST_AUTH_DIR

%w[
  security_components
  authentication
  access_control
  identity
].each do |f|
  require f
end
