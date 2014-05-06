require "bundler/gem_tasks"
require 'rspec/core/rake_task'

task :default => :initialize

task :initialize do

  bashrc = "#{ENV['HOME']}/.bashrc"
  aliaz_is_installed = !! File.open(bashrc, 'r').read.index(/aliaz aliases --bash/)

  unless aliaz_is_installed
    File.open(bashrc, 'a') do |bashrc|
      bashrc.puts ""
      bashrc.puts '#Loading Aliaz aliases'
      bashrc.puts 'source /dev/stdin <<<  $(aliaz aliases --bash)'
      bashrc.puts ""
    end
  end

end

RSpec::Core::RakeTask.new do |task|
  task.rspec_opts = ['--color', '--format', 'doc']
end
