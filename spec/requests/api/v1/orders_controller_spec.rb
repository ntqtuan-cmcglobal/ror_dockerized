require 'rails_helper'

RSpec.describe 'Api::V1::OrdersController', type: :request do
  let(:buyer) { FactoryBot.create(:user, full_name: Faker::Name.name, email: Faker::Internet.email, password: 'password123', role: 'buyer') }
  let(:seller) { FactoryBot.create(:user, full_name: Faker::Name.name, email: Faker::Internet.email, password: 'password123', role: 'seller') }
  let(:product1) { FactoryBot.create(:product, user_id: seller.id, name: Faker::Commerce.product_name, price: 100) }
  let(:product2) { FactoryBot.create(:product, user_id: seller.id, name: Faker::Commerce.product_name, price: 200) }

  let(:token) { 'Bearer testtoken' }

  before do
    # Stub Doorkeeper authentication
    allow_any_instance_of(Api::V1::OrdersController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::OrdersController).to receive(:current_user).and_return(buyer)
    allow_any_instance_of(Api::V1::OrdersController).to receive(:authorize).and_return(true)
  end

  describe 'GET /api/v1/orders' do
    let!(:orders) do
      FactoryBot.create(
        :order,
        user_id: buyer.id,
        status: OrderStatus::UNPAID,
        total_price: product1.price,
        order_items: [FactoryBot.build(
          :order_item,
          product_id: product1.id,
          quantity: 1,
          price: product1.price
        )]
      )

      FactoryBot.create(
        :order,
        user_id: buyer.id,
        status: OrderStatus::UNPAID,
        total_price: product2.price,
        order_items: [FactoryBot.build(
          :order_item,
          product_id: product2.id,
          quantity: 1,
          price: product2.price
        )]
      )
    end

    it 'returns a list of orders for the current user' do
      get '/api/v1/orders', headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe 'GET /api/v1/orders/:id' do
    let!(:order) { FactoryBot.create(:order, user: buyer, status: OrderStatus::UNPAID, total_price: product1.price, order_items: [FactoryBot.build(:order_item, product_id: product1.id, quantity: 1, price: product1.price)]) }

    it 'returns the order details' do
      get "/api/v1/orders/#{order.id}", headers: { 'Authorization' => token }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(order.id)
    end
  end

  describe 'POST /api/v1/orders' do
    let!(:product) { FactoryBot.create(:product, user: buyer, name: Faker::Commerce.product_name, price: Faker::Commerce.price) }

    it 'creates a new order' do
      expect do
        post '/api/v1/orders', params: { order: { order_items_attributes: [{ product_id: product.id }] } },
                               headers: { 'Authorization' => token }
      end.to change(Order, :count).by(1)
      File.open('tmp/response.html', 'w') { |f| f.write(response.body) }
      expect(response).to have_http_status(:created)
    end

    it 'returns errors for invalid params' do
      post '/api/v1/orders', params: { order: { order_items_attributes: [] } }, headers: { 'Authorization' => token }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to be_present
    end
  end
end
