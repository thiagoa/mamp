require 'mamp/version'
require 'mamp/server_runner'

module Mamp
  COMMAND_FLAG_REGEX = /(.+)-(.+)-command/

  def build_command_flag(command)
    :"#{command.action}-#{command.server}-command"
  end

  def register_commands!(global_flags)
    global_flags.each_with_object([]) do |flag, ret|
      flag_id, flag_value = flag
      matches = flag_id.to_s.match(COMMAND_FLAG_REGEX)

      if matches
        action, server = matches[1], matches[2]
        ServerRunner.add_command Command.new(action.to_sym, server.to_sym, flag_value)
      end
    end
  end

  def detect_invalid_servers!(servers)
    invalid_servers = servers.map(&:to_sym).select do |s|
      !ServerRunner.server_ids.include?(s)
    end

    unless invalid_servers.empty?
      servers = invalid_servers.join(', ')
      raise ArgumentError, "Invalid servers: #{servers}. #{supported_servers}"
    end
  end

  def supported_servers
    "Supported servers: #{ServerRunner.servers.map(&:id).join(', ')}."
  end
end
