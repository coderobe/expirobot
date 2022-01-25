require "expirobot"

config = Expirobot::Config.global
config.load! "config.yml"

Signal.trap("HUP") do
  warn "[#{Time.now}] SIGHUP received, reloading configuration"
  config.load!
end

map "/health" do
  run -> {[200, {"Content-Type" => "text/plain"}, ["OK"]]}
end

map "/" do
  run Expirobot::Server.new
end
