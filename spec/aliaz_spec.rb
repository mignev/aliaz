require 'spec_helper'

describe "Aliaz" do

  before(:each) do
    @real_home = ENV['HOME']
    ENV['HOME'] = "/tmp"

    @aliaz = Aliaz::Aliaz.new
    @conf_path = "#{ENV['HOME']}/.aliazconf"
  end

  after(:each) do
    if File.exist? @conf_path
      File.delete @conf_path
    end

    ENV['HOME'] = @real_home
  end

  describe "Aliaz" do

    it 'should have set default conf_path' do
      expect(@aliaz.conf_path).to eq @conf_path
    end

    describe "Creating aliases" do
      before(:each) do
        @aliaz.add "app_name", "app_alias", "alias value"
      end

      it 'should have created conf file' do
        expect(File).to exist @conf_path
      end

      it 'should conf file be created only once' do
        @aliaz.add "app_name", "app_alias", "alias value"
        expect(File.read(@conf_path)).to_not eq ''

      end

      it 'should have alias in conf file' do
        conf = YAML::load_file @conf_path
        expect(conf['app_name']['app_alias']).to eq 'alias value'
      end

      it 'should have 2 aliases for an app' do
        @aliaz.add "app_name", "app_alias1", "alias value1"
        conf = YAML::load_file @conf_path
        expect(conf['app_name']['app_alias']).to eq 'alias value'
        expect(conf['app_name']['app_alias1']).to eq 'alias value1'
      end

      it 'should have aliases for multiple apps' do
        @aliaz.add "app_name", "app_alias1", "alias value1"
        @aliaz.add "app_name1", "app_alias", "alias value"

        conf = YAML::load_file @conf_path

        expect(conf['app_name']['app_alias']).to eq 'alias value'
        expect(conf['app_name']['app_alias1']).to eq 'alias value1'
        expect(conf['app_name1']['app_alias']).to eq 'alias value'
      end

    end

    describe 'Removing aliases' do

      it 'remove app alias from conf with only one alias' do
        @aliaz.add "app_name", "app_alias", "value"
        @aliaz.remove "app_name", "app_alias"

        conf = YAML::load_file @conf_path

        conf['app_name'].should be_empty
      end

      it 'remove not existing alias' do
        @aliaz.add "app_name", "app_alias", "value"

        expect { @aliaz.remove "app_name", "app_alias1" }.to_not raise_error

        conf = YAML::load_file @conf_path

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
        expect( aliases ).to eq "app_name() {\n\tlocal cmd='';\n\tlocal args=\"${@:2}\";\n\tif [[ $1 == 'app_alias' ]]; then\n\t\talias_arguments='value'\n\t\tcmd=\"$alias_arguments $args\";\n\tfi;\n\tif [ -z \"$cmd\" ]; then\n\t\tcmd=\"$@\";\n\tfi;\n\tcommand app_name $cmd;\n\n};app_name1() {\n\tlocal cmd='';\n\tlocal args=\"${@:2}\";\n\tif [[ $1 == 'app_alias1' ]]; then\n\t\talias_arguments='value1'\n\t\tcmd=\"$alias_arguments $args\";\n\tfi;\n\tif [ -z \"$cmd\" ]; then\n\t\tcmd=\"$@\";\n\tfi;\n\tcommand app_name1 $cmd;\n\n};"
      end

      it 'get all aliases for specific app redy for bash source' do
        @aliaz.add "app_name", "app_alias", "value"
        @aliaz.add "app_name1", "app_alias1", "value1"
        aliases = @aliaz.aliases "app_name", :format => :bash

        # FIXME: This is very ugly
        expect( aliases ).to eq "app_name() {\n\tlocal cmd='';\n\tlocal args=\"${@:2}\";\n\tif [[ $1 == 'app_alias' ]]; then\n\t\talias_arguments='value'\n\t\tcmd=\"$alias_arguments $args\";\n\tfi;\n\tif [ -z \"$cmd\" ]; then\n\t\tcmd=\"$@\";\n\tfi;\n\tcommand app_name $cmd;\n\n};"
      end
    end

  end

end
