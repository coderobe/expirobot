# frozen_string_literal: true

require "sinatra/base"
require "rufus-scheduler"

module Expirobot
  class Server < ::Sinatra::Base
    configure :development, :production do
      enable :logging
    end

    #helpers do
      def config; @config ||= Expirobot::Config.global; end

      def get_room client, mxid
        room = mxid if mxid.start_with? ?!
        room ||= client.join_room(mxid).room_id if mxid.start_with? ?#
        room ||= MatrixSdk::Client.new(client).direct_room(mxid).id if mxid.start_with? ?@
        room
      end
    #end

    configure do
      schedule = Rufus::Scheduler.new
      set :schedule, schedule

      # TODO: key check schedule here
      #schedule.every "1d" do
      #  puts "foo"
      #end
    end

    get "/" do
      # TODO: more comprehensive status overview
      {
        status: :success,
        keys_monitored: config.rules.map(&:key),
      }.to_json
    end

    get "/status/:id" do
      key_id = params[:id]
      halt 400, "Missing key id" unless key_id

      rules = (config.rules(key_id) rescue [])
      halt 404, "No rules configured for key id" if rules.empty?

      logger.debug "got status request for #{key_id}, rules: #{rules}"

      rules.each do |rule|
        client = rule.client
        halt 500, "Unable to acquire Matrix client from rule" unless client

        rule.notify.each do |id|
          room = get_room client, id
          halt 500, "Unable to acquire Matrix room for #{room} from rule and client" unless room

          # Support rules with nil client explicitly specified, for testing
          next unless client.is_a? MatrixSdk::Api

          # TODO: remove test message
          client.send_message_event(room, "m.room.message",
                                    { msgtype: rule.msgtype,
                                      body: "check executed on #{key_id}",
                                      # TODO: formatted response body
                                      # formatted_body: html,
                                      # format: "org.matrix.custom.html"
                                    })
        end
      end

      {
        status: :success,
        key: key_id,
      }.to_json
    end
  end
end
