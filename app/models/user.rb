# frozen_string_literal: true

# User model handles authentication, roles, and associations with products, orders, carts, and tokens.
class User < ApplicationRecord
  # Pagination
  paginates_per 10

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken',
                           foreign_key: :resource_owner_id, dependent: :destroy

  # Active Storage
  has_one_attached :avatar

  def admin?
    role == 'admin'
  end

  def buyer?
    role == 'buyer'
  end

  def seller?
    role == 'seller'
  end

  def self.authenticate(params)
    user = find_for_authentication(email: params[:email])
    user if user&.valid_password?(params[:password])
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[email role created_at updated_at full_name]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
