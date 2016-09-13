Sequel.migration do
    change do
        add_column :sent_messages, :sent_to_group, String
    end
end
