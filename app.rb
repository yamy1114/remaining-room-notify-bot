Bundler.require
require 'open-uri'

include Clockwork

Dotenv.load

URL = 'https://travel.yahoo.co.jp/dhotel/shisetsu/HT10020366/IKYU/10950168/10013731?ci=20201202&co=20201203&rm=1&adlt=2'

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

$previous_room_count = nil

every(1.hour, tz: 'Asia/Tokyo') do
  begin
    text = nil
    room_count = nil

    remaining_room_info_element = get_remaining_room_info_element

    if remaining_room_info_element.nil?
      room_count = nil
      text = 'まだまだヨユーだロボ！'
    else
      room_count = remaining_room_info_element.text.match(/\d+/)[0].to_i
      text =  "あと#{room_count}部屋だロボ！"
    end

    text += "\n#{URL}"

    client.broadcast(text_message_json('残り部屋数が変わったヨ')) if $previous_room_count != room_count
    client.broadcast(text_message_json(text)) if $previous_room_count != room_count || [9, 21].include?(Time.now.hour)

    $previous_room_count = room_count
  rescue => ex
    client.broadcast(text_message_json("エラー\n#{ex.message}"))
  end
end

