require 'test_helper'
require 'mamp'

class MampCommandsTest < Test::Unit::TestCase
  include Mamp

  def setup
    @apache = Server.new :apache, 'Apache'
    @start_apache = Command.new :start, :apache, 'sudo /usr/sbin/apachectl start'

    ServerRunner.add_server @apache
    ServerRunner.add_command @start_apache
  end

  def teardown
    ServerRunner.remove_servers!
    ServerRunner.remove_commands!
  end

  def test_it_fails_when_dealing_with_invalid_servers
    exception = assert_raise ArgumentError do
      detect_invalid_servers! %i{apache mysql postgresql}
    end

    assert_match /mysql, postgresql/, exception.message
    assert_not_match /apache, mysql, postgresql/, exception.message
  end

  def test_it_register_commands_from_gli_global_flags
    register_commands!({
      :'stop-apache-command' => 'sudo /usr/sbin/apachectl stop',
      :'start-mysql-command' => 'sudo /usr/local/bin/mysql.server start',
    })

    ServerRunner.find_command! :stop,  :apache
    ServerRunner.find_command! :start, :mysql
  end
end
