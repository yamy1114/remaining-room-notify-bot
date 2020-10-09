Bundler.require
require 'open-uri'

Dotenv.load

URL = 'https://travel.yahoo.co.jp/dhotel/shisetsu/HT10024471/IKYU/10919248/10029392/?ci=20201202&co=20201203&rm=1&adlt=2'

def client
  Line::Bot::Client.new do |config|
    config.channel_secret = ENV.fetch('LINE_BOT_CHANNEL_SECRET')
    config.channel_token = ENV.fetch('LINE_BOT_CHANNEL_TOKEN')
  end
end

def get_remaining_room_info_element
  charset = nil
  html = open(URL) do |f|
    charset = f.charset
    f.read
  end

  page = Nokogiri::HTML.parse(html, nil, charset)
  page.css('.priceSummary_remaining')
end

def text_message_json(text)
  {
    type: 'text',
    text: text
  }
end

remaining_room_info_element = get_remaining_room_info_element

text = if remaining_room_info_element.nil?
         'まだまだヨユーだロボ👌'
       else
         binding.pry
         remaining_room_count = remaining_room_info_element.text.match(/\d+/)[0].to_i
         "あと#{remaining_room_count}部屋だロボ🤖"
       end

text += "\n#{URL}"

client.broadcast(text_message_json(text))

binding.pry

p :finish

