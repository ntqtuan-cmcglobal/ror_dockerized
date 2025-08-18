class ImportFile < ApplicationRecord
  belongs_to :user
  has_one_attached :import_file

  validates :import_file, presence: true
end
