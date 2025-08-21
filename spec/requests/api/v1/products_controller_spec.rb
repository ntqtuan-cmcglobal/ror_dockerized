# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Products', type: :request do
  let(:seller) { FactoryBot.create(:user, full_name: Faker::Name.name, email: Faker::Internet.email, password: 'password123', role: 'seller') }
  let(:buyer) { FactoryBot.create(:user, full_name: Faker::Name.name, email: Faker::Internet.email, password: 'password123', role: 'buyer') }
  let(:category) { FactoryBot.create(:category, name: Faker::Commerce.department) }
  let!(:product1) do
    FactoryBot.create(
      :product,
      name: 'Test Product',
      price: 100,
      category: category,
      user: seller
    )
  end
  let!(:product2) do
    FactoryBot.create(
      :product,
      name: 'Another Product',
      price: 200,
      category: category,
      user: seller
    )
  end
  let(:token) { 'Bearer testtoken' }

  before do
    # Stub Doorkeeper authentication
    allow_any_instance_of(Api::V1::ProductsController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::ProductsController).to receive(:current_user).and_return(buyer)
    allow_any_instance_of(Api::V1::ProductsController).to receive(:authorize).and_return(true)
  end

  describe 'GET /api/v1/products' do
    it 'returns all products' do
      get '/api/v1/products', headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(2)
    end

    it 'filters by name' do
      get '/api/v1/products', params: { filters: { name: 'Test' } }, headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)
      expect(json_response['data'][0]['name']).to eq('Test Product')
    end

    it 'filters by price range' do
      get '/api/v1/products', params: { filters: { min_price: 150, max_price: 250 } },
                              headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)
      expect(json_response['data'][0]['name']).to eq('Another Product')
    end

    it 'filters by category' do
      get '/api/v1/products', params: { filters: { category_id: category.id } }, headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)
      expect(json_response['data'][0]['category']['id']).to eq(category.id)
    end

    it 'filters by user' do
      get '/api/v1/products', params: { filters: { user_id: buyer.id } }, headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).to all(include('user_id' => buyer.id))
    end

    it 'sorts by price desc' do
      get '/api/v1/products', params: { sort: 'price:desc' }, headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)
      expect(json_response['data'][0]['name']).to eq('Another Product')
    end

    it 'paginates results' do
      get '/api/v1/products', params: { page: 1, per_page: 1 }, headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)
      expect(json_response['pagination']['current_page']).to eq(1)
      expect(json_response['data'].size).to eq(1)
    end
  end

  describe 'GET /api/v1/products/:id' do
    it 'returns the product' do
      get "/api/v1/products/#{product1.id}", headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(product1.id)
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
