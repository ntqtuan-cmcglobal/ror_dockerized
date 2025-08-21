class AddErrorMessageToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :error_message, :string
  end
end
