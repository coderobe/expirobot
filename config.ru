require "expirobot"

bot = Expirobot::Server.new

map "/" do
  run bot
end
