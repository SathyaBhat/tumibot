require 'httparty'
require 'yaml'
require 'logger'
require 'sequel'
require_relative 'lib/update'

version = '0.0.3'
start_message = "Don't be a lolgor. Can't you see it's running?"
stop_message  = "This is like lolkid trying to stop something he can't"

$log          = Logger.new('log/tumibot.log')
token         = YAML.load_file('config/secrets.yaml')["tumibot"]["token"]
last_offset   = YAML.load_file('config/offset.yaml')['offset']
confidence    = YAML.load_file('config/user_confidence_levels.yaml')

def bot_should_post(chats, confidence)  
  if confidence.fetch(chats.from_username, nil).nil?
    $log.info("#{chats.from_username} info not found")
    return false
  end

  if rand() > confidence[chats.from_username]['level']
     $log.info("#{chats.from_username} exceeded confidence level #{confidence[chats.from_username]['level']}")
     return true
  end
end

def reply_to_message(message_id, group_id, text, token)
  options = {
    body: {
      chat_id: group_id,
      text: text,
      reply_to_message_id: message_id
    }
  }
  $log.debug("Posting #{text} to #{group_id}")
  response = HTTParty.post("https://api.telegram.org/bot#{token}/sendMessage",options)
end

def write_offset_to_file(last_offset)
  data = {}
  data['offset'] = last_offset
  File.write('config/offset.yaml', YAML.dump(data))
  $log.debug("offset at: #{last_offset}, wrote to file")
end

last_posted_time = Time.now.to_i

while true
  begin
    response = HTTParty.get("https://api.telegram.org/bot#{token}/getUpdates?offset=#{last_offset+1}")
  rescue Net::OpenTimeout => e
      $log.debug e.message  
      $log.debug e.backtrace.inspect
      sleep 60
  end

  if response['ok']
    result = response['result']
    interval = 60*rand(1..5)
    result.each do |r|
      chats = Update.new
      chats.update_id = r['update_id']

      # if a message has been edited then the hash key changes from 
      # 'message' to edited message. So we replace them with below

      r['message']          = r.delete 'edited_message' if r['message'].nil?
      chats.message_id      = r['message']['message_id']
      chats.from_id         = r['message']['from']['id']
      chats.from_first_name = r['message']['from']['first_name']
      chats.from_last_name  = r['message']['from']['last_name']
      chats.from_username   = r['message']['from']['username'].downcase
      chats.group_title     = r['message']['chat']['title']
      chats.group_id        = r['message']['chat']['id']
      chats.chat_text       = r['message']['text']

      if r['message']['forward_from'].nil?
        chats.chat_received_date = r['message']['date']
        chats.forwarded_chat     = 'N'
      else
        chats.chat_received_date = r['message']['forward_date']
        chats.forwarded_chat     = 'Y'
      end

      begin
        chats.save
      rescue Sequel::UniqueConstraintViolation => e
        $log.debug("Warning: Unique constraint error raised on #{chats.update_id}")
      end
      

      if chats.chat_text == '/version' || chats.chat_text == '/version@tumi_bot'
        reply_to_message(chats.message_id, chats.group_id, version, token)
      elsif chats.chat_text =~ /\/start/
        reply_to_message(chats.message_id, chats.group_id, start_message, token)
      elsif chats.chat_text =~ /expect/i
        reply_to_message(chats.message_id, chats.group_id, confidence.fetch('expect').fetch('chats', nil).sample, token)
      elsif chats.chat_text =~ /posh/i
        reply_to_message(chats.message_id, chats.group_id, confidence.fetch('posh').fetch('chats', nil).sample, token)
      elsif chats.chat_text =~ /watch/i
        reply_to_message(chats.message_id, chats.group_id, confidence.fetch('watch').fetch('chats', nil).sample, token)
      elsif chats.chat_text =~ /\/stop/
        reply_to_message(chats.message_id, chats.group_id, stop_message, token)
      else
        $log.debug("Won't post before till #{interval + last_posted_time}, current time: #{Time.now.to_i}. Interval: #{interval} Last posted time: #{last_posted_time}")
        if Time.now.to_i >  interval + last_posted_time
          if bot_should_post(chats, confidence) and r['message']['new_chat_participant'].nil? and r['message']['left_chat_participant'].nil?
            what_to_post     = confidence.fetch(chats.from_username).fetch('chats', nil)
            reply_to_message(chats.message_id, chats.group_id, what_to_post.sample, token) if not what_to_post.nil?
            last_posted_time = Time.now.to_i
          end
        end
      end
      write_offset_to_file(chats.update_id) 
      last_offset = chats.update_id
    end
  end
  sleep 4
end
