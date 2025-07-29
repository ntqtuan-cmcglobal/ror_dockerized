class AddErrorMessageToProduct < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :error_message, :text, null: true, default: nil
  end
end
