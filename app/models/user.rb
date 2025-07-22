class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :products, dependent: :destroy
  has_one :cart, dependent: :destroy

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
end
