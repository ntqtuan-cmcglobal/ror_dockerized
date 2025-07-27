class AddIsDraftToProduct < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :is_draft, :boolean, default: false, null: false
  end
end
