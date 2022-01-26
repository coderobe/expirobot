# frozen_string_literal: true

require "matrix_sdk"
require "psych"

module Expirobot
  class Config
    Rule = Struct.new(:config, :data) do
      def key
        data.fetch(:key)
      end

      def notify
        data.fetch(:notify, [])
      end

      def ignore
        data.fetch(:ignore, [])
      end

      def ignored? key
        ignore.include? key
      end

      def matrix
        data.fetch(:matrix)
      end

      def msgtype
        data.fetch(:msgtype, config.default_msgtype)
      end

      def client
        return Object.new if matrix.nil?

        @client ||= config.client(matrix)
      end
    end

    def self.global
      @global ||= self.new
    end

    def initialize(config = {})
      if config.is_a? String
        file = config
        config = {}
      end
      @config = config
      @clients = {}

      load!(file) if file
    end

    def load!(filename = "config.yml")
      raise "No such file" unless File.exist? filename

      @config = Psych.load(File.read(filename))
      self
    end

    def default_msgtype
      @config.fetch("msgtype", "m.text")
    end

    def client(client_name = nil)
      client_name ||= @config["matrix"].first["name"]
      raise "No client name provided" unless client_name

      client_data = @config["matrix"].find{|m| m["name"] == client_name}
      raise "No client configuration found for name given" unless client_data

      @clients[client_name] ||= begin
        client_data = client_data.dup.transform_keys{|key| key.to_sym rescue key}

        MatrixSdk::Api.new(client_data[:url], **client_data.reject{|k, _v| %i[url].include? k})
      end
    end

    def rules(key_id=nil)
      @config["rules"].select{|m| key_id.nil? || m["key"] == key_id}.map do |rule_data|
        rule_data = rule_data.dup.transform_keys{|key| key.to_sym rescue key}

        Rule.new self, rule_data
      end
    end

    def rule(key_id)
      rules(key_id).first
    end

    def delete_rule(key_id)
      @config["rules"].delete @config["rules"].find{|m| m["key"] == key_id}
    end
  end
end
