class AddTableChatRoom < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_rooms, id: false do |t|
      t.string :chat_room_id, null: false, primary_key: true
      t.column :user_ids, :integer, array: true, default: [], null: false
      t.timestamps
    end

    add_column :messages, :chat_room_id, :string
    add_foreign_key :messages, :chat_rooms, column: :chat_room_id, primary_key: :chat_room_id
    add_index :messages, :chat_room_id
    add_index :chat_rooms, :user_ids, unique: true
  end
end
