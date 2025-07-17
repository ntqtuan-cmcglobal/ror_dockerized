require 'rails_helper'

RSpec.describe 'Carts', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:buyer) do
    FactoryBot.create(
      :user,
      full_name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      password: 'password',
      role: 'buyer'
    )
  end

  let(:other_user) do
    FactoryBot.create(
      :user,
      full_name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      password: 'password',
      role: 'seller'
    )
  end

  let(:product) do
    FactoryBot.create(
      :product,
      name: Faker::Commerce.product_name,
      price: Faker::Commerce.price,
      user: other_user
    )
  end

  let(:cart) do
    FactoryBot.create(:cart, user: buyer, cart_items: [])
  end

  describe 'GET /carts' do
    context 'as a buyer' do
      before do
        sign_in buyer
        buyer.cart = cart
      end

      it 'returns a successful response' do
        get cart_path
        expect(response).to have_http_status(:ok)
      end
    end

    context 'as a non-buyer' do
      before { sign_in other_user }

      it 'denies access' do
        get cart_path
        expect(response).to have_http_status(:forbidden).or have_http_status(:redirect)
      end
    end
  end

  describe 'POST /carts/add_item' do
    context 'as a buyer' do
      before do
        sign_in buyer
        buyer.cart = cart
      end

      it 'adds a product to the cart' do
        initial_count = buyer.cart.cart_items.count
        post add_item_cart_path(product.id), params: {}
        expect(buyer.cart.cart_items.count).to eq(initial_count + 1)
        expect(response).to have_http_status(:redirect).or have_http_status(:ok)
      end

      it 'does not add a product with invalid params' do
        expect do
          post add_item_cart_path(-1), params: {}
        end.not_to(change { buyer.cart.cart_items.count })
        expect(response).not_to have_http_status(:ok)
      end
    end

    context 'as a non-buyer' do
      before { sign_in other_user }

      it 'denies access to add item' do
        post add_item_cart_path(product.id), params: {}
        expect(response).to have_http_status(:forbidden).or have_http_status(:redirect)
      end
    end

    context 'when not signed in' do
      it 'redirects to sign in' do
        post add_item_cart_path(product.id), params: {}
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
