require 'rails_helper'
require 'faker'

RSpec.describe 'Orders', type: :request do
  include Devise::Test::IntegrationHelpers
  let!(:buyer) do
    FactoryBot.create(
      :user,
      full_name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      password: 'password',
      role: 'buyer'
    )
  end

  let!(:seller) do
    FactoryBot.create(
      :user,
      full_name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      password: 'password',
      role: 'seller'
    )
  end

  let!(:product) do
    FactoryBot.create(
      :product,
      name: Faker::Commerce.product_name,
      price: 100,
      user_id: seller.id
    )
  end

  let!(:order) do
    FactoryBot.create(
      :order,
      user_id: buyer.id,
      status: OrderStatus::UNPAID,
      total_price: product.price,
      order_items: [FactoryBot.build(
        :order_item,
        product_id: product.id,
        quantity: 1,
        price: product.price
      )]
    )
  end

  before { sign_in buyer }

  describe 'GET /orders' do
    it 'returns http success' do
      get orders_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /orders/:id' do
    it 'shows the order' do
      get order_path(order)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /orders' do
    let!(:cart) do
      cart = FactoryBot.create(:cart, user: buyer)
      FactoryBot.create(:cart_item, cart: cart, product: product, quantity: 1)
      cart
    end

    it 'creates an order from cart' do
      post orders_path, params: { order: { cart_id: cart.id } }
      expect(Order.count).to eq(1)
      created_order = Order.order(:created_at).last
      expect(response).to redirect_to(cart_path(cart))
      expect(created_order.total_price).to eq(product.price)
      expect(created_order.order_items.count).to eq(1)
      expect(created_order.status).to eq(OrderStatus::UNPAID)
    end

    it 'fails if cart not found' do
      post orders_path, params: { order: { cart_id: 9999 } }
      expect(response).to redirect_to(cart_path(buyer.cart))
      expect(flash[:alert]).to eq('Failed to create order. Please check your input.')
    end
  end

  describe 'POST /orders/:id/cancel_order' do
    let(:product1) do
      FactoryBot.create(
        :product,
        name: Faker::Commerce.product_name,
        price: Faker::Commerce.price,
        user_id: seller.id
      )
    end

    let(:unpaid_order) do
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
    end

    let(:product2) do
      FactoryBot.create(
        :product,
        name: Faker::Commerce.product_name,
        price: Faker::Commerce.price,
        user_id: seller.id
      )
    end

    let(:paid_order) do
      FactoryBot.create(
        :order,
        user_id: buyer.id,
        status: OrderStatus::PAID,
        total_price: product2.price,
        order_items: [FactoryBot.build(
          :order_item,
          product_id: product2.id,
          quantity: 1,
          price: product2.price
        )]
      )
    end

    it 'cancels unpaid order' do
      post cancel_order_path(unpaid_order)
      expect(response).to redirect_to(unpaid_order)
      expect(unpaid_order.reload.status).to eq(OrderStatus::CANCELLED)
    end

    it 'does not cancel paid order' do
      post cancel_order_path(paid_order)
      expect(response).to redirect_to(paid_order)
      expect(flash[:alert]).to eq('Only unpaid orders can be cancelled.')
    end
  end
end
