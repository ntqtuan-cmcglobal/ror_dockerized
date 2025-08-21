require 'rails_helper'

RSpec.describe PaymentsController, type: :request do
  include Devise::Test::IntegrationHelpers
  let(:admin) { FactoryBot.create(:user, full_name: Faker::Name.name, role: 'admin', email: Faker::Internet.email, password: 'Password123!') }
  let(:seller) { FactoryBot.create(:user, full_name: Faker::Name.name, role: 'seller', email: Faker::Internet.email, password: 'Password123!') }
  let(:buyer) { FactoryBot.create(:user, full_name: Faker::Name.name, role: 'buyer', email: Faker::Internet.email, password: 'Password123!') }
  let(:product) { FactoryBot.create(:product, user_id: seller.id, name: Faker::Commerce.product_name, price: 100) }
  let(:order) do
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
  let(:payment) { FactoryBot.create(:payment, order: order, result: PaymentResult::PENDING, payment_method: 'bank_transfer') }

  before { sign_in admin }

  describe 'GET #index' do
    it 'renders the index template' do
      get order_payments_path(order)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Payments')
    end
  end

  describe 'GET #new' do
    it 'renders the new template for buyer' do
      sign_in buyer
      get new_order_payment_path(order)
      expect(response).to have_http_status(:ok)
    end

    it 'redirects if not buyer' do
      sign_in seller
      get new_order_payment_path(order)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('You are not authorized to perform this action.')
    end

    it 'redirects if order not found' do
      sign_in buyer
      get new_order_payment_path(order_id: 99_999)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('Order not found')
    end
  end

  describe 'POST #create' do
    it 'creates a payment and redirects' do
      post order_payments_path(order), params: {
        payment: {
          order_id: order.id,
          payment_method: 'bank_transfer'
        }
      }
      expect(response).to redirect_to(order_payments_url(order))
      follow_redirect!
      expect(response.body).to include('Payment created.')
    end
    it 'renders new on failure' do
      allow_any_instance_of(Payment).to receive(:save).and_return(false)
      post order_payments_path(order), params: {
        payment: {
          order_id: order.id,
          payment_method: 'bank_transfer'
        }
      }
      expect(response.body).to include('New Payment')
    end
  end

  describe 'POST #mark_as_paid' do
    before do
      sign_out admin
      sign_in seller
    end

    it 'marks bank transfer payment as paid' do
      post mark_as_paid_payments_path(payment)
      expect(response).to redirect_to(order_payments_url(order))
      follow_redirect!
      expect(response.body).to include('Payment was marked as paid.')
    end
  end

  describe 'GET #check_stripe_payment' do
    it 'redirects with success if payment is paid' do
      stripe_payment = FactoryBot.create(:payment, order: order, payment_method: 'stripe',
                                                   stripe_session_id: 'sess_123')
      allow(Stripe::Checkout::Session).to receive(:retrieve).and_return(double(payment_status: 'paid'))
      get payment_check_stripe_payment_path(stripe_payment.id)
      expect(response).to redirect_to(order_payments_url(order))
      follow_redirect!
      expect(response.body).to include('Payment was successful.')
    end
    it 'redirects with alert if payment not completed' do
      stripe_payment = FactoryBot.create(:payment, order: order, payment_method: 'stripe',
                                                   stripe_session_id: 'sess_123')
      allow(Stripe::Checkout::Session).to receive(:retrieve).and_return(double(payment_status: 'unpaid'))
      get payment_check_stripe_payment_path(stripe_payment.id)
      expect(response).to redirect_to(order_payments_url(order))
      follow_redirect!
      expect(response.body).to include('Payment not completed.')
    end
    it 'redirects with alert if not stripe payment' do
      get payment_check_stripe_payment_path(payment.id)
      expect(response).to redirect_to(order_payments_url(order))
      follow_redirect!
      expect(response.body).to include('Payment method is not Stripe.')
    end
  end
end
