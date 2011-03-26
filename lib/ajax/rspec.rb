Dir[File.join(File.dirname(__FILE__), 'rspec', '*')].map do |file|
  require file
end