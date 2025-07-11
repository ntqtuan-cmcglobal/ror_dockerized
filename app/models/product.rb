class Product < ApplicationRecord
  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Associations
  # has_many :orders, dependent: :destroy
  belongs_to :user

  belongs_to :category, optional: true

  # Scopes
  def owned_by?(user)
    self.user == user
  end
end
