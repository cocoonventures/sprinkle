require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Installers::Runner do

  before do
    @package = double(Sprinkle::Package, :name => 'package', :sudo? => false)
  end

  def create_runner(*cmds)
    options=cmds.extract_options!
    Sprinkle::Installers::Runner.new(@package, cmds, options)
  end

  describe 'when created' do
    it 'should accept a single cmd to run' do
      @installer = create_runner 'teste'
      @installer.cmds.should eq ['teste']
    end

    it 'should accept an array of commands to run' do
      @installer = create_runner ['teste', 'world']
      @installer.cmds.should eq ['teste', 'world']
      @installer.install_sequence.should eq ['teste', 'world']
    end
  end

  describe 'during installation' do

    it 'should use sudo if specified locally' do
      @installer = create_runner 'teste', :sudo => true
      @install_commands = @installer.send :install_commands
      @install_commands.should eq ['sudo teste']
    end

    it "should accept env options and convert to uppercase" do
      @installer = create_runner 'command1', :env => {
        :z => 'foo',
        :PATH => '/some/path',
        :user => 'deploy',
        :a => 'bar'
      }
      @install_commands = @installer.send :install_commands
      command_parts = @install_commands.first.split(/ /)

      command_parts.shift.should eq 'env'
      command_parts.pop.should eq 'command1'

      command_parts.should =~ ['PATH=/some/path', 'USER=deploy', 'Z=foo', 'A=bar']

    end

    it "should accept multiple commands" do
      @installer = create_runner 'teste', 'test2'
      @install_commands = @installer.send :install_commands
      @install_commands.should eq ['teste','test2']
    end

    it 'should run the given command for all specified packages' do
      @installer = create_runner 'teste'
      @install_commands = @installer.send :install_commands
      @install_commands.should eq ['teste']
    end
  end
end
