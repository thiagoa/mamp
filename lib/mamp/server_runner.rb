require 'open3'

module Mamp
  Command = Struct.new(:action, :server, :command, :present_participle)
  Server  = Struct.new(:id, :description)

  class ServerRunner
    def self.add_server(server)
      servers << server
    end

    def self.servers
      @servers ||= []
    end

    def self.server_ids
      servers.map(&:id)
    end

    def self.remove_servers!
      @servers = nil
    end

    def self.find_server!(id)
      server = servers.detect do |s|
        s.id == id.to_sym
      end

      if server.nil?
        raise ArgumentError, "Server #{id} not found"
      end

      server
    end

    def self.add_command(command)
      existing = commands.detect do |c|
        c.action == command.action && c.server == command.server
      end

      if existing
        existing.command = command.command
      else
        commands << command
      end
    end

    def self.commands
      @commands ||= []
    end

    def self.command_actions
      commands.map { |c| c.action }.uniq
    end

    def self.find_command!(action, server)
      command = commands.detect do |c|
        action.to_sym == c.action && server.to_sym == c.server
      end

      if command.nil?
        raise ArgumentError, "Command #{action} not found"
      end

      command
    end

    def self.remove_commands!
      @commands = nil
    end

    attr_reader :server, :command, :out, :error

    def initialize(server_id, command_id)
      @server  = self.class.find_server! server_id
      @command = self.class.find_command! command_id, server_id
    end

    def success?
      @success
    end

    def run!
      @out, @error, status = Open3.capture3 @command.command
      @success = status.success?
    end
  end
end
