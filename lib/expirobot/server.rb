# frozen_string_literal: true

require "logger"
require "sinatra/base"
require "rufus-scheduler"
require "net/http"
require "gpgme"

module Expirobot
  class Server < ::Sinatra::Base
    def logger
      @logger ||= Logger.new(STDOUT, formatter: proc {|severity, datetime, progname, msg|
        "[#{datetime}] #{severity}  #{msg}\n"
      })
    end
    def config; @config ||= Expirobot::Config.global; end
    def schedule; @schedule ||= Rufus::Scheduler.singleton; end

    def initialize
      logger.info "Starting..."
      reload

      # TODO: key check schedule here
      #schedule.every "1d" do
      #  puts "foo"
      #end

      logger.info "Started, hand-off!"
      super
    end

    def reload
      logger.info "Loading config"
      config.load!

      config.rules.each do |rule|
        key_id = rule.key
        logger.info "Updating key with id #{key_id}"
        keyserver = URI "https://keyserver.ubuntu.com/pks/lookup"
        keyserver.query = URI.encode_www_form({ op: "get", search: "0x#{key_id}" })
        res = Net::HTTP.get_response keyserver
        if res.is_a? Net::HTTPSuccess
          logger.info "Fetched from keyserver, importing..."
          GPGME::Key.import res.body
        else
          logger.warn "Couldn't fetch from keyserver, relying on cached keyring"
        end

        key = GPGME::Key.get key_id
        logger.info "Found key #{key.fingerprint} #{key.expires}"
        key.uids.each do |uid|
          logger.info "... has UID #{uid.name} (#{uid.email})"
          logger.warn "UID invalid" if uid.invalid?
          logger.warn "UID revoked" if uid.revoked?
        end
        key.subkeys.each do |sub|
          logger.info "... has subkey #{sub.fingerprint}"
          logger.warn "Subkey expired on #{sub.expires}" if sub.expired
        end
      end
    end

    def get_room client, mxid
      room = mxid if mxid.start_with? ?!
      room ||= client.join_room(mxid).room_id if mxid.start_with? ?#
      room ||= MatrixSdk::Client.new(client).direct_room(mxid).id if mxid.start_with? ?@
      room
    end

    get "/" do
      # TODO: more comprehensive status overview
      {
        status: :success,
        keys_monitored: config.rules.map(&:key),
        any_expired: config.rules.map{|k| GPGME::Key.get(k.key).subkeys.map(&:expired)}.flatten.reduce{|a,b| a||b}
      }.to_json
    end

    get "/:id" do
      key_id = params[:id]
      halt 400, { status: :fail, message: "Missing key id" }.to_json unless key_id

      rules = (config.rules(key_id) rescue [])
      halt 404, { status: :fail, message: "No rules configured for key id" }.to_json if rules.empty?

      rules.each do |rule|
        client = rule.client
        halt 500, { status: :fail, message: "Unable to acquire Matrix client from rule" }.to_json unless client

        rule.notify.each do |id|
          room = get_room client, id
          halt 500, { status: :fail, message: "Unable to acquire Matrix room for #{room} from rule and client" }.to_json unless room

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
        expired: GPGME::Key.get(key_id).subkeys.map(&:expired).reduce{|a,b| a||b},
        uids: GPGME::Key.get(key_id).uids.map{|uid| "#{uid.name} (#{uid.email})"},
        keys: GPGME::Key.get(key_id).subkeys.map{|key| {
          id: key.fingerprint,
          expiry: key.expires?? key.expires.to_i : 0,
          expired: key.expired,
        }},
      }.to_json
    end
  end
end
