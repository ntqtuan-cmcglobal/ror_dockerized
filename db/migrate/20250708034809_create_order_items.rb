class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.timestamps
      t.datetime :deleted_at
      t.index %i[order_id product_id], unique: true, name: 'index_order_items_on_order_and_product'
    end
  end
end
