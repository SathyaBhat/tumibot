Sequel.migration do
    change do
        add_column :sent_messages, :sent_at, Date
    end
end
