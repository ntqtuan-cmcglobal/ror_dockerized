class AddEncryptedFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :encrypted_phone, :string
    add_column :users, :encrypted_phone_iv, :string

    add_index :users, :encrypted_phone_iv, unique: true

    remove_column :users, :phone, :string
  end
end
