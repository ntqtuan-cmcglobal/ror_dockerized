require 'rails_helper'

RSpec.describe Administration::OrdersController, type: :request do
  include Devise::Test::IntegrationHelpers
  let(:admin) { FactoryBot.create(:user, full_name: Faker::Name.name, role: 'admin', email: Faker::Internet.email, password: 'Password123!') }
  let(:seller) { FactoryBot.create(:user, full_name: Faker::Name.name, role: 'seller', email: Faker::Internet.email, password: 'Password123!') }
  let(:buyer) { FactoryBot.create(:user, full_name: Faker::Name.name, role: 'buyer', email: Faker::Internet.email, password: 'Password123!') }
  let(:product1) { FactoryBot.create(:product, user_id: seller.id, name: Faker::Commerce.product_name, price: 100) }
  let(:product2) { FactoryBot.create(:product, user_id: seller.id, name: Faker::Commerce.product_name, price: 200) }
  let!(:order) do
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

  before { sign_in admin }

  describe 'GET #index' do
    it 'renders the index template' do
      get administration_orders_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Orders')
    end
  end

  describe 'GET #show' do
    it 'renders the show template' do
      get administration_order_path(order)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(order.id.to_s)
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get new_administration_order_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    it 'creates a new order and redirects' do
      new_product = FactoryBot.create(:product, user_id: seller.id, name: Faker::Commerce.product_name, price: 300)
      post administration_orders_path, params: {
        order: {
          user_id: buyer.id,
          product_ids: [new_product.id]
        }
      }
      expect(response).to redirect_to(administration_order_path(Order.last))
      follow_redirect!
      expect(response.body).to include('Order was successfully created.')
    end

    it 'renders new on failure' do
      allow_any_instance_of(Order).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Order.new))
      post administration_orders_path, params: {
        order: {
          user_id: buyer.id,
          product_ids: [product1.id]
        }
      }
      expect(response.body).to include('Failed to create order')
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      get edit_administration_order_path(order)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH #update' do
    it 'updates the order and redirects' do
      patch administration_order_path(order), params: {
        order: {
          user_id: buyer.id,
          product_ids: [product1.id]
        }
      }
      expect(response).to redirect_to(administration_order_path(order))
      follow_redirect!
      expect(response.body).to include('Order was successfully updated.')
    end

    it 'renders edit on failure' do
      allow_any_instance_of(Order).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(order))
      patch administration_order_path(order), params: {
        order: {
          user_id: buyer.id,
          product_ids: [product1.id]
        }
      }
      expect(response.body).to include('Failed to update order')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the order and redirects' do
      new_product = FactoryBot.create(:product, user_id: seller.id, name: Faker::Commerce.product_name, price: 150)
      order_to_delete = FactoryBot.create(
        :order,
        user_id: buyer.id,
        status: OrderStatus::UNPAID,
        total_price: new_product.price,
        order_items: [FactoryBot.build(
          :order_item,
          product_id: new_product.id,
          quantity: 1,
          price: new_product.price
        )]
      )
      delete administration_order_path(order_to_delete)
      expect(response).to redirect_to(administration_orders_path)
      follow_redirect!
      expect(response.body).to include('Order was successfully deleted.')
    end
  end
end
