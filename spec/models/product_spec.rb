require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.create!(full_name: Faker::Name.name, email: Faker::Internet.unique.email, password: 'password')
      product = Product.new(name: Faker::Commerce.product_name, price: Faker::Commerce.price(range: 0..100.0),
                            user: user)
      expect(product).to be_valid
    end

    it 'is invalid without a name' do
      user = User.create!(full_name: Faker::Name.name, email: Faker::Internet.unique.email, password: 'password')
      product = Product.new(name: nil, price: Faker::Commerce.price(range: 0..100.0), user: user)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a name longer than 100 characters' do
      user = User.create!(full_name: Faker::Name.name, email: Faker::Internet.unique.email, password: 'password')
      long_name = 'a' * 101
      product = Product.new(name: long_name, price: Faker::Commerce.price(range: 0..100.0), user: user)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include('is too long (maximum is 100 characters)')
    end

    it 'is invalid without a price' do
      user = User.create!(full_name: Faker::Name.name, email: Faker::Internet.unique.email, password: 'password')
      product = Product.new(name: Faker::Commerce.product_name, price: nil, user: user)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("can't be blank")
    end

    it 'is invalid with a negative price' do
      user = User.create!(full_name: Faker::Name.name, email: Faker::Internet.unique.email, password: 'password')
      product = Product.new(name: Faker::Commerce.product_name, price: -1, user: user)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include('must be greater than or equal to 0')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:category).optional }
  end

  describe '#owned_by?' do
    it 'returns true if the product belongs to the user' do
      user = User.create!(full_name: Faker::Name.name, email: Faker::Internet.unique.email, password: 'password')
      product = Product.create!(name: Faker::Commerce.product_name, price: Faker::Commerce.price(range: 0..100.0),
                                user: user)
      expect(product.owned_by?(user)).to be true
    end

    it 'returns false if the product does not belong to the user' do
      user1 = User.create!(full_name: Faker::Name.name, email: Faker::Internet.unique.email,
                           password: Faker::Internet.password(min_length: 8))
      user2 = User.create!(full_name: Faker::Name.name, email: Faker::Internet.unique.email,
                           password: Faker::Internet.password(min_length: 8))
      product = Product.create!(name: Faker::Commerce.product_name, price: Faker::Commerce.price(range: 0..100.0),
                                user: user1)
      expect(product.owned_by?(user2)).to be false
    end
  end
end
