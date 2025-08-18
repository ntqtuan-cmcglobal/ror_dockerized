require 'sidekiq'

class ImportCsvFileProductsJob
  include Sidekiq::Worker
  sidekiq_options queue: 'import_csv_file_products', retry: false

  def perform(import_file_id, current_user_id)
    csv = CsvService.new
    import_file_record = ImportFile.find(import_file_id)
    current_user = User.find(current_user_id)

    csv.import_file(
      'Product',
      import_file_record,
      current_user
    )
  end
end
