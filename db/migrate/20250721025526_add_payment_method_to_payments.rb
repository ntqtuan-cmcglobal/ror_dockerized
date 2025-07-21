class AddPaymentMethodToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :payment_method, :string, null: false
    add_index :payments, :payment_method
  end
end
