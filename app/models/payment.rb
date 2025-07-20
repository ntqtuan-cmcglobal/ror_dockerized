class Payment < ApplicationRecord
    # Associations
    belongs_to :user, optional: true
    belongs_to :order, optional: true

    # Validations
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :status, presence: true

    # Scopes
    scope :recent, -> { order(created_at: :desc) }
end