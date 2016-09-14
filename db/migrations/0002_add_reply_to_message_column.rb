Sequel.migration do
    change do
        add_column :sent_messages, :reply_to_message, String
    end
end
