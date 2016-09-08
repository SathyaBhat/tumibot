require 'sequel'

def set_up_tables(db)
    begin
        db.create_table :received_mesages do
            primary_key :update_id
            Integer :message_id 
            Integer :from_id 
            String  :from_username 
            String  :from_first_name 
            String  :from_last_name 
            String  :group_id
            String  :group_title
            String  :chat_received_date
            String  :chat_text
            String  :forwarded_chat
        end
    rescue Sequel::Error => e
        p e.message
    end

    begin
        db.create_table :sent_messages do
            primary_key :id
            Integer :message_id
            String :chat_text
            Date :sent_at
        end
    rescue Sequel::Error => e
        p e.message
    end
end

def connect_to_db
    return Sequel.connect('sqlite://db/tumibot.db')
end

db = connect_to_db
set_up_tables(db)