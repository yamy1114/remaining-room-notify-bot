Bundler.require


Dotenv.load

client = Line::Bot::Client.new do |config|
  config.channel_secret = ENV.fetch('LINE_BOT_CHANNEL_SECRET')
  config.channel_token = ENV.fetch('LINE_BOT_CHANNEL_TOKEN')
end

client.broadcast('ロボだよ🤖')

binding.pry

p :finish

