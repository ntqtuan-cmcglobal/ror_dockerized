require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#admin?' do
    it 'returns true if role is admin' do
      user = User.new(role: 'admin')
      expect(user.admin?).to be true
    end

    it 'returns false if role is not admin' do
      user = User.new(role: 'buyer')
      expect(user.admin?).to be false
    end
  end

  describe '#buyer?' do
    it 'returns true if role is buyer' do
      user = User.new(role: 'buyer')
      expect(user.buyer?).to be true
    end

    it 'returns false if role is not buyer' do
      user = User.new(role: 'seller')
      expect(user.buyer?).to be false
    end
  end

  describe '#seller?' do
    it 'returns true if role is seller' do
      user = User.new(role: 'seller')
      expect(user.seller?).to be true
    end

    it 'returns false if role is not seller' do
      user = User.new(role: 'admin')
      expect(user.seller?).to be false
    end
  end

  describe '#products' do
    it 'returns products owned by the user' do
      user = User.create!(
        full_name: Faker::Name.name,
        email: Faker::Internet.unique.email,
        password: Faker::Internet.password(min_length: 8)
      )
      product = user.products.create!(
        name: Faker::Commerce.product_name,
        price: Faker::Commerce.price(range: 10..1000)
      )
      expect(user.products).to include(product)
    end
  end
end
