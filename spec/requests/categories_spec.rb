require 'rails_helper'

RSpec.describe 'Categories', type: :request do
  include Devise::Test::IntegrationHelpers
  let!(:user) { User.create!(full_name: Faker::Name.name, email: Faker::Internet.email, password: Faker::Internet.password, role: 'admin') }
  let!(:category) { Category.create!(name: Faker::Commerce.department) }

  before do
    sign_in user
  end

  describe 'GET /categories' do
    it 'returns a list of categories' do
      get categories_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /categories/:id' do
    it 'returns the category' do
      get category_path(category)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /categories' do
    let(:valid_params) { { category: { name: 'New Category' } } }

    it 'creates a new category' do
      expect do
        post categories_path, params: valid_params
      end.to change(Category, :count).by(1)
    end
  end

  describe 'PATCH /categories/:id' do
    it 'updates the category' do
      patch category_path(category), params: { category: { name: 'Updated' } }
      expect(response).to redirect_to(category_path(category))
      category.reload
      expect(category.name).to eq('Updated')
    end
  end

  describe 'DELETE /categories/:id' do
    it 'deletes the category' do
      expect do
        delete category_path(category)
      end.to change(Category, :count).by(-1)
    end
  end
end
