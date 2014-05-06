require 'thor'
require 'aliaz/aliaz'

module Aliaz
  class CLI < Thor
    desc "add APP.ALIAS VALUE", "Adding alias for app."
    def add(app_and_alias, *alias_value)

      app_alias = app_and_alias.split(".")
      app = app_alias[0]
      the_alias = app_alias[1..-1].join('.')
      the_alias_value = alias_value.join(' ')

      if the_alias.empty? || the_alias_value.empty?
        puts "Ups ... you miss to add the name or value of the alias :)"
        puts "Try something like this: 'aliaz add app.alias value' :)"
        return 1
      end

      aliaz = Aliaz.new
      aliaz.add app, the_alias, the_alias_value
      puts "Alias '#{the_alias}' with value '#{the_alias_value}' was created successfully!"

      0
    end

    desc "remove APP ALIAS", "Removing alias from app"
    def remove(app_name, app_alias)
      begin
        aliaz = Aliaz.new
        aliaz.remove app_name, app_alias
        puts "Alias '#{app_alias}' was removed successfully!"
        return 0
      rescue NotExistingAppError
        puts "The app '#{app_name}' does not exist!"
        return 1
      end
    end

    desc "aliases", "Shows all aliases"
    method_option :bash, :type => :boolean, :default => false
    def aliases(app_name=nil)
      aliaz = Aliaz.new
      if options[:bash]
        puts aliaz.aliases :format => :bash
      else
        puts "\nList of aliases"
        puts aliaz.aliases(app_name).to_yaml
      end
      0
    end
  end
end
