class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.timestamps
      t.datetime :deleted_at
    end
  end
end
