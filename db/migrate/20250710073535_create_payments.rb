class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :result, null: false, default: 'pending'
      t.timestamps
      t.datetime :deleted_at, null: true
    end
  end
end
