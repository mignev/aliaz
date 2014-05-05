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
      rescue NotExistingAppError
        puts "The app '#{app_name}' does not exist!"
      end

      0
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
