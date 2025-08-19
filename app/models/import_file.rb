class ImportFile < ApplicationRecord
  belongs_to :user
  has_one_attached :import_file

  paginates_per 5

  validates :import_file, presence: true

  # Scope for visible files
  def self.visible_to(user)
    if user.admin?
      all
    else
      where(user: user)
    end
  end
end
