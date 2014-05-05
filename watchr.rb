watch('spec/(.*)\.rb') { |md| run "rspec --color" }
watch('lib/(.*)\.rb') { |md| run "rspec --color" }

def run( cmd )
    system 'clear'
    output = system cmd
end
