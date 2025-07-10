class CreateImportFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :import_files do |t|
      t.references :user, null: false, foreign_key: true
      t.string :file_path, null: false
      t.string :status, null: false, default: 'waiting_for_upload'
      t.timestamps
      t.datetime :deleted_at, null: true
    end
  end
end
