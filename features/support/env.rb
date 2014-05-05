require 'aruba/cucumber'

Before do
  @real_home = ENV['HOME']
  ENV['HOME'] = "/tmp"

  @conf_path = "#{ENV['HOME']}/.aliazconf"
end

After do
  if File.exist? @conf_path
    File.delete @conf_path
  end

  ENV['HOME'] = @real_home
end
