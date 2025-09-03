class Message < ApplicationRecord
  belongs_to :user

  validates :content, presence: true

  # Scope
  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :from_user, ->(user) { where(user: user) }
end
