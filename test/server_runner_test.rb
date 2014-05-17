require 'test_helper'
require 'mamp'

class ServerRunnerTest < Test::Unit::TestCase
  include Mamp

  def setup
    ServerRunner.add_server Server.new :mysql, 'MySQL'
    ServerRunner.add_command Command.new(
      :start,
      :mysql,
      '/usr/local/bin/mysql.server start',
      'Starting MySQL...'
    )
  end

  def teardown
    ServerRunner.remove_servers!
    ServerRunner.remove_commands!
  end

  def test_it_runs_when_server_exists
    stringio = StringIO.new
    status_stub = Object.new
    def status_stub.success?; true; end

    Open3.expects(:capture3).with('/usr/local/bin/mysql.server start').returns([
      'stdout',
      nil,
      status_stub
    ])

    run_servers! :start, ['mysql'], {}, stringio
    assert_match /Starting MySQL.../, stringio.string
  end

  def test_it_fails_when_server_does_not_exist
    exception = assert_raise ArgumentError do
      run_servers! :stop, ['postgresql'], {}
    end

    assert_equal 'Invalid servers: postgresql. Supported servers: mysql.', exception.message
  end

  def test_it_fails_when_command_does_not_exist
    exception = assert_raise ArgumentError do
      run_servers! :stop, ['mysql'], {}
    end

    assert_match /not found/, exception.message
  end
end
