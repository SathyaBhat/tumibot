require 'sequel'

Sequel.connect('sqlite://db/tumibot.db')

class Update < Sequel::Model(:received_mesages)
end

class Sent_Message < Sequel::Model(:sent_messages)
end