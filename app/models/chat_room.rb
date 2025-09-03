class ChatRoom < ApplicationRecord
  # Associations
  has_many :messages, foreign_key: :chat_room_id

  # Validations
  validates :user_ids, presence: true

  # Scopes
  scope :with_user, ->(user_id) { where('user_ids @> ARRAY[?]::integer[]', user_id) }

  def self.find_or_create_by_user_ids(user_ids)
    chat_room = with_user(user_ids).first
    chat_room || create(chat_room_id: SecureRandom.uuid.gsub('-', ''), user_ids: user_ids)
  end
end
