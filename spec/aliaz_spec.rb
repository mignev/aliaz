require 'spec_helper'

describe "Aliaz" do

  before(:each) do
    @real_home = ENV['HOME']
    ENV['HOME'] = "/tmp"

    @aliaz = Aliaz::Aliaz.new
    @aliazconf = "#{ENV['HOME']}/.aliazconf"
  end

  after(:each) do
    if File.exist? @aliazconf
      File.delete @aliazconf
    end

    ENV['HOME'] = @real_home
  end

  describe "Aliaz" do

    it 'should have set default aliazconf' do
      expect(@aliaz.aliazconf).to eq @aliazconf
    end

    describe "Creating aliases" do
      before(:each) do
        @aliaz.add "app_name", "app_alias", "alias value"
      end

      it 'should have created conf file' do
        expect(File).to exist @aliazconf
      end

      it 'should conf file be created only once' do
        @aliaz.add "app_name", "app_alias", "alias value"
        expect(File.read(@aliazconf)).to_not eq ''

      end

      it 'should have alias in conf file' do
        conf = @aliaz.load_aliases
        expect(conf['app_name']['app_alias']).to eq 'alias value'
      end

      it 'should have 2 aliases for an app' do
        @aliaz.add "app_name", "app_alias1", "alias value1"
        conf = @aliaz.load_aliases
        expect(conf['app_name']['app_alias']).to eq 'alias value'
        expect(conf['app_name']['app_alias1']).to eq 'alias value1'
      end

      it 'should have aliases for multiple apps' do
        @aliaz.add "app_name", "app_alias1", "alias value1"
        @aliaz.add "app_name1", "app_alias", "alias value"

        conf = @aliaz.load_aliases

        expect(conf['app_name']['app_alias']).to eq 'alias value'
        expect(conf['app_name']['app_alias1']).to eq 'alias value1'
        expect(conf['app_name1']['app_alias']).to eq 'alias value'
      end

    end

    describe 'Removing aliases' do

      it 'remove app alias from conf with only one alias' do
        @aliaz.add "app_name", "app_alias", "value"
        @aliaz.remove "app_name", "app_alias"

        conf = @aliaz.load_aliases

        conf['app_name'].should be_empty
      end

      it 'remove not existing alias' do
        @aliaz.add "app_name", "app_alias", "value"

        expect { @aliaz.remove "app_name", "app_alias1" }.to_not raise_error

        conf = @aliaz.load_aliases

        conf['app_name']['app_alias'].should eql 'value'
      end

      it 'remove alias from not existing app' do
        @aliaz.add "app_name", "app_alias", "value"
        expect { @aliaz.remove "not_existing_app", "app_alias" }.
          to raise_error(Aliaz::NotExistingAppError, "App with name 'not_existing_app' is not exist!")
      end

    end

    describe 'Get aliases' do

      it 'get all aliases' do
        @aliaz.add "app_name", "app_alias", "value"
        @aliaz.add "app_name1", "app_alias1", "value1"
        aliases = @aliaz.aliases

        expect( aliases['app_name']['app_alias'] ).to eq 'value'
        expect( aliases['app_name1']['app_alias1'] ).to eq 'value1'
      end

      it 'get all aliases for specific app' do
        @aliaz.add "app_name", "app_alias", "value"
        @aliaz.add "app_name1", "app_alias1", "value1"
        aliases = @aliaz.aliases 'app_name'

        expect( aliases['app_name']['app_alias'] ).to eq 'value'
      end

      it 'get all aliases redy for bash source' do
        @aliaz.add "app_name", "app_alias", "value"
        @aliaz.add "app_name1", "app_alias1", "value1"
        aliases = @aliaz.aliases :format => :bash

        # FIXME: This is very ugly
        expect( aliases ).to eq "aliaz() {\nlocal all_args=\"\";\nfor arg in \"$@\"; do\n\tif [[ \"$arg\" =~ \" \" ]]; then\n\t\tall_args=\"${all_args} \\\"${arg}\\\"\";\n\telse\n\t\tall_args=\"$all_args $arg\";\n\tfi;\ndone;\n\n\tall_args=($(echo ${all_args}));\n\tlocal cmd='';\n\tlocal args=\"${all_args[@]:1}\";\n\tif [[ $1 == 'add' ]] || [[ $1 == 'remove' ]]; then\n\t\teval command aliaz $all_args && source /dev/stdin <<<  $(aliaz aliases --bash);\n\telse\n\tif [ -z \"$cmd\" ]; then\n\t\tcmd=\"${all_args[@]}\";\n\tfi;\n\teval command aliaz $cmd;\n\tfi\n};\n\napp_name() {\nlocal all_args=\"\";\nfor arg in \"$@\"; do\n\tif [[ \"$arg\" =~ \" \" ]]; then\n\t\tall_args=\"${all_args} \\\"${arg}\\\"\";\n\telse\n\t\tall_args=\"$all_args $arg\";\n\tfi;\ndone;\n\n\tall_args=($(echo ${all_args}));\n\tlocal cmd='';\n\tlocal args=\"${all_args[@]:1}\";\n\tif [[ $1 == 'app_alias' ]]; then\n\t\talias_arguments='value'\n\t\tcmd=\"$alias_arguments $args\";\n\tfi;\n\tif [ -z \"$cmd\" ]; then\n\t\tcmd=\"${all_args[@]}\";\n\tfi;\n\teval command app_name $cmd;\n\n};\n\napp_name1() {\nlocal all_args=\"\";\nfor arg in \"$@\"; do\n\tif [[ \"$arg\" =~ \" \" ]]; then\n\t\tall_args=\"${all_args} \\\"${arg}\\\"\";\n\telse\n\t\tall_args=\"$all_args $arg\";\n\tfi;\ndone;\n\n\tall_args=($(echo ${all_args}));\n\tlocal cmd='';\n\tlocal args=\"${all_args[@]:1}\";\n\tif [[ $1 == 'app_alias1' ]]; then\n\t\talias_arguments='value1'\n\t\tcmd=\"$alias_arguments $args\";\n\tfi;\n\tif [ -z \"$cmd\" ]; then\n\t\tcmd=\"${all_args[@]}\";\n\tfi;\n\teval command app_name1 $cmd;\n\n};\n\n"
      end

      it 'get all aliases redy for bash source but with some custom aliaz aliases' do
        @aliaz.add "app_name", "app_alias", "value"
        @aliaz.add "app_name1", "app_alias1", "value1"
        @aliaz.add "aliaz", "all", "aliases"
        @aliaz.add "aliaz", "remove", "delete"
        aliases = @aliaz.aliases :format => :bash

        # FIXME: This is very ugly
        expect( aliases ).to eq "app_name() {\nlocal all_args=\"\";\nfor arg in \"$@\"; do\n\tif [[ \"$arg\" =~ \" \" ]]; then\n\t\tall_args=\"${all_args} \\\"${arg}\\\"\";\n\telse\n\t\tall_args=\"$all_args $arg\";\n\tfi;\ndone;\n\n\tall_args=($(echo ${all_args}));\n\tlocal cmd='';\n\tlocal args=\"${all_args[@]:1}\";\n\tif [[ $1 == 'app_alias' ]]; then\n\t\talias_arguments='value'\n\t\tcmd=\"$alias_arguments $args\";\n\tfi;\n\tif [ -z \"$cmd\" ]; then\n\t\tcmd=\"${all_args[@]}\";\n\tfi;\n\teval command app_name $cmd;\n\n};\n\napp_name1() {\nlocal all_args=\"\";\nfor arg in \"$@\"; do\n\tif [[ \"$arg\" =~ \" \" ]]; then\n\t\tall_args=\"${all_args} \\\"${arg}\\\"\";\n\telse\n\t\tall_args=\"$all_args $arg\";\n\tfi;\ndone;\n\n\tall_args=($(echo ${all_args}));\n\tlocal cmd='';\n\tlocal args=\"${all_args[@]:1}\";\n\tif [[ $1 == 'app_alias1' ]]; then\n\t\talias_arguments='value1'\n\t\tcmd=\"$alias_arguments $args\";\n\tfi;\n\tif [ -z \"$cmd\" ]; then\n\t\tcmd=\"${all_args[@]}\";\n\tfi;\n\teval command app_name1 $cmd;\n\n};\n\naliaz() {\nlocal all_args=\"\";\nfor arg in \"$@\"; do\n\tif [[ \"$arg\" =~ \" \" ]]; then\n\t\tall_args=\"${all_args} \\\"${arg}\\\"\";\n\telse\n\t\tall_args=\"$all_args $arg\";\n\tfi;\ndone;\n\n\tall_args=($(echo ${all_args}));\n\tlocal cmd='';\n\tlocal args=\"${all_args[@]:1}\";\n\tif [[ $1 == 'all' ]]; then\n\t\talias_arguments='aliases'\n\t\tcmd=\"$alias_arguments $args\";\n\tfi;\n\tif [[ $1 == 'remove' ]]; then\n\t\talias_arguments='delete'\n\t\tcmd=\"$alias_arguments $args\";\n\tfi;\n\tif [[ $1 == 'add' ]] || [[ $1 == 'remove' ]]; then\n\t\teval command aliaz $all_args && source /dev/stdin <<<  $(aliaz aliases --bash);\n\telse\n\tif [ -z \"$cmd\" ]; then\n\t\tcmd=\"${all_args[@]}\";\n\tfi;\n\teval command aliaz $cmd;\n\tfi\n};\n\n"
      end

      it 'get all aliases for specific app redy for bash source' do
        @aliaz.add "app_name", "app_alias", "value"
        @aliaz.add "app_name1", "app_alias1", "value1"
        aliases = @aliaz.aliases "app_name", :format => :bash

        # FIXME: This is very ugly
        expect( aliases ).to eq "aliaz() {\nlocal all_args=\"\";\nfor arg in \"$@\"; do\n\tif [[ \"$arg\" =~ \" \" ]]; then\n\t\tall_args=\"${all_args} \\\"${arg}\\\"\";\n\telse\n\t\tall_args=\"$all_args $arg\";\n\tfi;\ndone;\n\n\tall_args=($(echo ${all_args}));\n\tlocal cmd='';\n\tlocal args=\"${all_args[@]:1}\";\n\tif [[ $1 == 'add' ]] || [[ $1 == 'remove' ]]; then\n\t\teval command aliaz $all_args && source /dev/stdin <<<  $(aliaz aliases --bash);\n\telse\n\tif [ -z \"$cmd\" ]; then\n\t\tcmd=\"${all_args[@]}\";\n\tfi;\n\teval command aliaz $cmd;\n\tfi\n};\n\napp_name() {\nlocal all_args=\"\";\nfor arg in \"$@\"; do\n\tif [[ \"$arg\" =~ \" \" ]]; then\n\t\tall_args=\"${all_args} \\\"${arg}\\\"\";\n\telse\n\t\tall_args=\"$all_args $arg\";\n\tfi;\ndone;\n\n\tall_args=($(echo ${all_args}));\n\tlocal cmd='';\n\tlocal args=\"${all_args[@]:1}\";\n\tif [[ $1 == 'app_alias' ]]; then\n\t\talias_arguments='value'\n\t\tcmd=\"$alias_arguments $args\";\n\tfi;\n\tif [ -z \"$cmd\" ]; then\n\t\tcmd=\"${all_args[@]}\";\n\tfi;\n\teval command app_name $cmd;\n\n};\n\n"
      end
    end

  end

end
