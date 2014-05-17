require 'test_helper'
require 'mamp/server_runner'

class ServerTest < Test::Unit::TestCase
  include Mamp

  def setup
    @apache     = Server.new :apache,   'Apache'
    @postgresql = Server.new :postgres, 'PostgreSQL'

    ServerRunner.add_server @apache
    ServerRunner.add_server @postgresql

    @stop_mysql = Command.new(
      :stop,
      :mysql,
      '/usr/local/bin/mysql.server stop',
      'Stopping MySQL...'
    )

    @start_postgres = Command.new(
      :start,
      :postgres,
      '/usr/local/bin/postgres -D /usr/local/var/postgres',
      'Starting PostgreSQL...'
    )

    @stop_apache = Command.new(
      :stop,
      :apache,
      'sudo /usr/sbin/apachectl stop',
      'Stopping Apache...'
    )

    ServerRunner.add_command @stop_mysql
    ServerRunner.add_command @start_postgres
    ServerRunner.add_command @stop_apache
  end

  def teardown
    ServerRunner.remove_server! @apache
    ServerRunner.remove_server! @postgresql

    ServerRunner.remove_command! @stop_mysql
    ServerRunner.remove_command! @start_postgres
    ServerRunner.remove_command! @stop_apache
  end

  def test_it_finds_an_existing_server
    assert_equal @apache,     ServerRunner.find_server!(:apache)
    assert_equal @postgresql, ServerRunner.find_server!(:postgres)
  end

  def test_it_fails_when_trying_to_find_a_non_existing_server
    assert_raise ArgumentError do
      ServerRunner.find_server! :mysql
    end
  end

  def test_it_finds_all_servers
    assert_equal [@apache, @postgresql], ServerRunner.servers
  end

  def test_it_finds_server_ids
    assert_equal [:apache, :postgres], ServerRunner.server_ids
  end

  def test_it_finds_an_existing_command
    assert_equal @stop_mysql,     ServerRunner.find_command!(:stop,  :mysql)
    assert_equal @start_postgres, ServerRunner.find_command!(:start, :postgres)
    assert_equal @stop_apache,    ServerRunner.find_command!(:stop,  :apache)
  end

  def test_it_fails_when_trying_to_find_a_non_existing_command
    assert_raise ArgumentError do
      ServerRunner.find_command! :start, :mysql
    end
  end

  def test_it_finds_all_commands
    assert_equal [@stop_mysql, @start_postgres, @stop_apache], ServerRunner.commands
  end

  def test_it_finds_a_command_line
    stop_mysql = ServerRunner.find_command!(:stop, :mysql)
    assert_equal '/usr/local/bin/mysql.server stop', stop_mysql.command
  end

  def test_it_replaces_current_command_when_command_object_already_exists
    ServerRunner.add_command Command.new(
      :stop,
      :apache,
      '/usr/sbin/httpd stop',
      'Original must be unmodified'
    )

    stop_apache = ServerRunner.find_command! :stop, :apache

    assert_equal '/usr/sbin/httpd stop', stop_apache.command
    assert_equal :apache, stop_apache.server
    assert_equal :stop, stop_apache.action
    assert_equal 'Stopping Apache...', stop_apache.present_participle

    assert_equal 3, ServerRunner.commands.size
  end

  def test_it_returns_all_distinct_command_actions
    assert_equal [:stop, :start], ServerRunner.command_actions
  end

  def test_it_runs_an_existing_command
    status_stub = Object.new
    def status_stub.success?; true; end

    Open3.expects(:capture3).with('sudo /usr/sbin/apachectl stop').returns([
      'stdout',
      nil,
      status_stub
    ])

    runner = ServerRunner.new(:apache, :stop)
    runner.run!

    assert_equal true, runner.success?
    assert_equal 'stdout', runner.out
    assert_nil runner.error
  end

  def test_it_fails_when_server_does_not_exist
    assert_raise ArgumentError do
      ServerRunner.new(:firebird, :start)
    end
  end

  def test_it_fails_when_command_does_not_exist
    assert_raise ArgumentError do
      ServerRunner.new(:mysql, :restart)
    end
  end
end
