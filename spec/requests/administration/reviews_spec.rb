require 'rails_helper'

RSpec.describe ReviewsController, type: :request do
  include Devise::Test::IntegrationHelpers
  let!(:admin) { FactoryBot.create(:user, full_name: Faker::Name.name, email: Faker::Internet.email, password: 'Password123!', role: 'admin') }
  let!(:seller) { FactoryBot.create(:user, full_name: Faker::Name.name, email: Faker::Internet.email, password: 'Password123!', role: 'seller') }
  let!(:buyer) { FactoryBot.create(:user, full_name: Faker::Name.name, email: Faker::Internet.email, password: 'Password123!', role: 'buyer') }
  let!(:product) { FactoryBot.create(:product, user: seller, name: Faker::Commerce.product_name, price: 100) }
  let!(:review) { FactoryBot.create(:review, product: product, user: buyer, rating: 4, comment: 'Great product!') }

  before { sign_in admin }

  describe 'GET #index' do
    it 'renders the index template and paginates order items' do
      get administration_reviews_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #show' do
    it 'redirects to the product page with correct params and anchor' do
      get administration_review_path(review)
      expect(response).to redirect_to(
        product_path(
          review.product_id,
          page: 1,
          anchor: "review-#{review.id}",
          highlight_review: review.id
        )
      )
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the review and redirects' do
      another_product = FactoryBot.create(:product, user: seller, name: Faker::Commerce.product_name, price: 150)
      review_to_delete = FactoryBot.create(:review, product: another_product, user: buyer, rating: 2, comment: 'Bad')
      delete administration_review_path(review_to_delete)
      File.open('tmp/response.html', 'w') { |f| f.write(response.body) }
      expect(response).to redirect_to(administration_reviews_path)
      follow_redirect!
      expect(response.body).to include('Review was successfully deleted.')
    end
  end
end
