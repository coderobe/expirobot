require "expirobot"

bot = Expirobot::Server.new

# TODO: this is broken, investigate
#Signal.trap("HUP") do
#  warn "[#{Time.now}] SIGHUP received, reloading configuration"
#  bot.reload
#end

map "/" do
  run bot
end
