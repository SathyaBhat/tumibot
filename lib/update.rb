require 'sequel'

Sequel.connect('sqlite://db/tumibot.db')

class Update < Sequel::Model(:received_mesages)
end