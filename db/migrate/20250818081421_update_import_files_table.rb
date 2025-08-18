class UpdateImportFilesTable < ActiveRecord::Migration[8.0]
  def change
    remove_column :import_files, :file_path, :string
    add_column :import_files, :error_message, :text
  end
end
