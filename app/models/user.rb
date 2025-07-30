class User < ApplicationRecord
  has_secure_password
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
    return user if user&.valid_password?(params[:password])

    nil
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[email role created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
