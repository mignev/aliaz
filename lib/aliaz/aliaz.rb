require 'yaml'

module Aliaz

  NotExistingAppError = Class.new(StandardError)

  class Aliaz

    def conf_path
      "#{ENV['HOME']}/.aliazconf"
    end

    def create_empty_conf_file
      unless File.exist? conf_path
        File.open(conf_path, 'w') {}
      end
    end

    def load_aliases
      YAML::load_file conf_path
    end

    def save_aliases(aliases)
      File.open conf_path, 'w' do |file|
        file.write aliases.to_yaml
      end
    end

    def add(app_name, app_alias, alias_value)
      create_empty_conf_file

      aliases = load_aliases

      unless aliases
        aliases = { app_name => { app_alias => alias_value }}
      end

      unless aliases[app_name]
        aliases[app_name] = { app_alias => alias_value }
      else
        aliases[app_name][app_alias] = alias_value
      end

      save_aliases aliases

    end

    def remove(app_name, app_alias)
      aliases = load_aliases

      begin
        aliases[app_name].delete app_alias
      rescue NameError
        raise NotExistingAppError.new "App with name '#{app_name}' is not exist!"
      end

      save_aliases aliases

    end

    def aliases(app_name=nil, **kwargs)
      create_empty_conf_file
      aliases = load_aliases

      if app_name
        app_aliases = aliases[app_name]
        aliases = {app_name => app_aliases}
      end

      if kwargs.has_key?(:format) && kwargs[:format] == :bash
        output = to_bash(aliases)
      else
        output = aliases
      end

      output
    end

    def to_bash(aliases)
      result = ""

      ## Workaraund. When we add a new alias want it to be available immediately.
      ## So ... we add hooks for aliaz to do that.
      ## TODO: This is little messy have to fix it!
      unless aliases.has_key? 'aliaz'
        result << bash_template('aliaz', {})
      end

      aliases.each do |app_name, app_aliases|
        result << bash_template(app_name, app_aliases)
      end

      result
    end

    def bash_template(app_name, aliases)
      result = "#{app_name}() {\n"

      result << "\tlocal cmd='';\n"
      result << "\t" << 'local args="${@:2}";' << "\n"

      aliases.each do |alias_name, arguments|
          result << "\tif [[ $1 == '#{alias_name}' ]]; then\n"
          result << "\t\talias_arguments='#{arguments}'\n"
          result << "\t\t" << 'cmd="$alias_arguments $args";' << "\n"
          result << "\tfi;\n"
      end

      ## TODO: try to avoid this workaround
      if app_name == 'aliaz'
        result << "\tif [[ $1 == 'add' ]] || [[ $1 == 'remove' ]]; then\n"
        result << "\t\tcommand aliaz $@ && source /dev/stdin <<<  $(aliaz aliases --bash);\n"
        result << "\telse\n"
        result << "\t" << 'if [ -z "$cmd" ]; then' << "\n"
        result << "\t\t" << 'cmd="$@";' << "\n"
        result << "\tfi;\n"

        result << "\tcommand #{app_name} $cmd;\n"
        result << "\tfi\n"
      else
        result << "\t" << 'if [ -z "$cmd" ]; then' << "\n"
        result << "\t\t" << 'cmd="$@";' << "\n"
        result << "\tfi;\n"

        result << "\tcommand #{app_name} $cmd;\n\n"
      end

      result << "};"

        result
    end

  end

end
