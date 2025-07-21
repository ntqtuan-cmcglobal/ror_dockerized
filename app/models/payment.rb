class Payment < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  belongs_to :order, optional: true

  # Validations
  validates :result, presence: true

  before_create :set_default_result

  private

  def set_default_result
    self.result ||= 'success' if payment_method == 'bank_transfer'

    self.result ||= 'undefined'
  end

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
end
