class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.references :user, null: false, foreign_key: true
      t.references :category, null: true, foreign_key: true
      t.decimal :average_rating, precision: 3, scale: 2, default: 0.0
      t.string :url
      t.timestamps
      t.datetime :deleted_at
    end
  end
end
