# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Products', type: :request do
  include Devise::Test::IntegrationHelpers
  let(:user) { User.create!(full_name: Faker::Name.name, email: Faker::Internet.email, password: Faker::Internet.password, role: 'buyer') }
  let(:category) { Category.create!(name: 'Electronics') }
  let(:valid_attributes) do
    { name: 'Laptop', price: 1000, user_id: user.id, category_id: category.id }
  end
  let(:invalid_attributes) do
    { name: '', price: -10, user_id: nil }
  end

  before do
    sign_in user
  end

  describe 'GET /products' do
    it 'returns a success response' do
      Product.create! valid_attributes
      get products_path
      pp 'start'
      p response.body
      pp 'end'
      expect(response).to be_successful
    end
  end

  describe 'GET /products/:id' do
    it 'returns a success response' do
      product = Product.create! valid_attributes
      get product_path(product)
      pp 'start'
      p response.body
      pp 'end'
      expect(response).to be_successful
    end
  end

  describe 'POST /products' do
    context 'with valid params' do
      it 'creates a new Product' do
        expect do
          post products_path, params: { product: valid_attributes }
        end.to change(Product, :count).by(1)
      end

      it 'redirects to the created product' do
        post products_path, params: { product: valid_attributes }
        expect(response).to redirect_to(Product.last)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Product' do
        expect do
          post products_path, params: { product: invalid_attributes }
        end.to change(Product, :count).by(0)
      end

      it 'renders the new template' do
        post products_path, params: { product: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PATCH /products/:id' do
    let(:product) { Product.create! valid_attributes }

    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Laptop' } }

      it 'updates the requested product' do
        patch product_path(product), params: { product: new_attributes }
        product.reload
        expect(product.name).to eq('Updated Laptop')
      end

      it 'redirects to the product' do
        patch product_path(product), params: { product: new_attributes }
        expect(response).to redirect_to(product)
      end
    end

    context 'with invalid params' do
      it 'renders the edit template' do
        patch product_path(product), params: { product: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE /products/:id' do
    it 'destroys the requested product' do
      product = Product.create! valid_attributes
      expect do
        delete product_path(product)
      end.to change(Product, :count).by(-1)
    end

    it 'redirects to the products list' do
      product = Product.create! valid_attributes
      delete product_path(product)
      expect(response).to redirect_to(products_url)
    end
  end
end
