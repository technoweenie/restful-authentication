
#
# Spew response onto screen -- painful but scrolling >> debugger
#
def dump_response
  # note that @request and @template won't to_yaml and that @session includes @cgi
  response_methods = response.instance_variables         - ['@request', '@template', '@cgi']
  request_methods  = response.request.instance_variables - ['@session_options_with_string_keys', '@cgi', '@session']
  response_methods.map!{|attr| attr.gsub(/^@/,'')}.sort!
  request_methods.map!{ |attr| attr.gsub(/^@/,'')}.sort!
  puts '', '*' * 75,
    response.instance_values.slice(*response_methods).to_yaml,
    "*" * 75, '',
    response.request.instance_values.slice(*request_methods).to_yaml,
    "*" * 75, ''
end
