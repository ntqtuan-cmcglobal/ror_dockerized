require 'rails_helper'

RSpec.describe Administration::PaymentsController, type: :request do
  include Devise::Test::IntegrationHelpers
  let(:admin) { FactoryBot.create(:user, full_name: Faker::Name.name, role: 'admin', email: Faker::Internet.email, password: 'Password123!') }
  let(:seller) { FactoryBot.create(:user, full_name: Faker::Name.name, role: 'seller', email: Faker::Internet.email, password: 'Password123!') }
  let(:buyer) { FactoryBot.create(:user, full_name: Faker::Name.name, role: 'buyer', email: Faker::Internet.email, password: 'Password123!') }
  let(:product) { FactoryBot.create(:product, user_id: seller.id, name: Faker::Commerce.product_name, price: 100) }
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
  let!(:payment1) { FactoryBot.create(:payment, order: order, result: 'success', payment_method: 'bank_transfer') }
  let!(:payment2) { FactoryBot.create(:payment, order: order, result: 'pending', payment_method: 'bank_transfer') }

  before { sign_in admin }

  describe 'GET #index' do
    it 'renders the index template and lists payments' do
      get administration_payments_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(payment1.id.to_s)
      expect(response.body).to include(payment2.id.to_s)
    end

    it 'filters payments by order user full name' do
      get administration_payments_path, params: { q: { order_user_full_name_cont: buyer.full_name } }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(payment1.id.to_s)
      expect(response.body).to include(payment2.id.to_s)
    end

    it 'returns no payments for unmatched user full name' do
      get administration_payments_path, params: { q: { order_user_full_name_cont: '!@#$' } }
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(payment1.id.to_s)
      expect(response.body).not_to include(payment2.id.to_s)
    end
  end
end
