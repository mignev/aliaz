watch('spec/(.*)\.rb') { |md| run "rspec --color" }
watch('lib/(.*)\.rb') { |md| run "rspec --color" }

def growl(message)
  growlnotify = `which growlnotify`.chomp
  title = "Watchr Test Results"
  message.gsub! /\[[0-9]+?m/, ''
  image = message.include?('0 failures, 0 errors') ? "~/.watchr_images/pass.png" : "~/.watchr_images/fail.png"
  options = "-w -n Watchr --image '#{File.expand_path(image)}' -m '#{message}' '#{title}'"
  system %(#{growlnotify} #{options} &)
end

def run( cmd )
    system 'clear'
    output = system cmd

    # if output:
    #     #system 'tmux rename-window -t 0 passed'
    #     #`tmux set-window-option -t 0 -g window-status-current-bg green`
    #     `tmux set -g status-bg green`
    #     growl('Tests OK!')
    # else
    #     #system 'tmux rename-window -t 0 failed'
    #     #`tmux set-window-option -t 0 -g window-status-current-bg red`
    #     `tmux set -g status-bg red`
    #     growl('Tests fail!')
    # end
end
