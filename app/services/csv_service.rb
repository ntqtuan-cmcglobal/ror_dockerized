# frozen_string_literal: true

require 'csv'

# Service for handling CSV import and export
class CsvService
  def export(objects, attributes)
    CSV.generate do |csv|
      csv << attributes.map(&:to_s)
      objects.each do |object|
        csv << attributes.map { |attr| object.public_send(attr) }
      end
    end
  end

  def import_file(model_class_name, import_file_record, current_user = nil)
    raise ArgumentError, 'File must be provided' unless import_file_record.import_file

    model_class = model_class_name.safe_constantize
    raise ArgumentError, "Model '#{model_class_name}' not found" unless model_class && model_class < ApplicationRecord

    process_import(
      model_class,
      import_file_record,
      current_user
    )
  end

  private

  def process_import(model_class, import_file_record, current_user)
    import_file_record.import_file.open do |file|
      CSV.foreach(file, headers: true) do |row|
        import_row(row, model_class, current_user)
      end
    end
    import_file_record.update(status: 'success')
  rescue StandardError => e
    import_file_record.update(status: 'error', error_message: e.message)
    raise e
  end

  def import_row(row, model_class, current_user)
    row_to_h = row.to_h

    row_to_h = process_product_row(row_to_h, current_user) if model_class.name == 'Product'

    record = model_class.find_by(id: row_to_h['id']) || model_class.new
    pp 'row_to_h:'
    pp row_to_h
    record.assign_attributes(row_to_h)
    log_import_result(record, model_class)
  end

  def process_product_row(row_to_h, current_user)
    category = Category.find_by(name: row_to_h['category_name'])
    row_to_h['category_id'] = category&.id || nil
    row_to_h.delete('category_name')
    row_to_h['user_id'] = current_user&.id
    row_to_h['is_draft'] = true
    row_to_h
  end

  def log_import_result(record, model_class)
    raise "Failed to import #{model_class.name}: #{record.errors.full_messages.join(', ')}" unless record.save

    puts "#{model_class.name} '#{record.respond_to?(:name) ? record.name : record.id}' imported successfully."
  end

  attr_reader :attributes, :objects, :header
end
