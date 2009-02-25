if File.exists(File.join(File.dirname(__FILE__), 'README'))
  puts IO.read(File.join(File.dirname(__FILE__), 'README'))
else
  puts IO.read(File.join(File.dirname(__FILE__), 'README.textile'))
end
