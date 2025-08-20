# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Products', type: :request do
  include Devise::Test::IntegrationHelpers
  let!(:user) { User.create!(full_name: Faker::Name.name, email: Faker::Internet.email, password: Faker::Internet.password, role: 'admin') }
  let!(:category) { Category.create!(name: 'Electronics') }
  let(:valid_attributes) do
    {
      name: 'Smartphone',
      description: 'Latest model with advanced features',
      price: 799.99,
      is_draft: false,
      user_id: user.id,
      category_id: category.id,
      digital_asset: Rack::Test::UploadedFile.new(
        Rails.root.join('spec/fixtures/files/sample.jpg'),
        'image/jpeg'
      )
    }
  end

  let(:invalid_attributes) do
    {
      name: '', # Name can't be blank
      description: '', # Description can't be blank
      price: -50, # Invalid price
      is_draft: nil,
      user_id: nil, # Missing user
      category_id: nil # Missing category
    }
  end

  before do
    sign_in user
  end

  describe 'GET /products' do
    it 'returns a success response' do
      Product.create! valid_attributes
      get products_path
      expect(response).to be_successful
    end
  end

  describe 'GET /products/:id' do
    it 'returns a success response' do
      product = Product.create! valid_attributes
      get product_path(product)
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
    it 'should destroy product and redirect to products_path with notice' do
      product = Product.create!(name: 'Laptop', price: 1000, user_id: user.id, category_id: category.id)

      expect do
        delete product_path(product)
      end.to change(Product, :count).by(-1)

      expect(response).to redirect_to(products_path)
      expect(flash[:notice]).to eq('Product was successfully deleted.')
    end

    it 'should not destroy product and redirect to product with alert if destroy fails' do
      product = Product.create!(name: 'Laptop', price: 1000, user_id: user.id, category_id: category.id)
      allow_any_instance_of(Product).to receive(:destroy).and_return(false)

      expect do
        delete product_path(product)
      end.not_to change(Product, :count)

      expect(response).to redirect_to(product_path(product))
      expect(flash[:alert]).to eq('Product could not be deleted.')
    end
  end

  describe 'POST /products/:id/save_review' do
    let!(:product) { Product.create!(valid_attributes) }
    let(:review_params) { { rating: 5, comment: 'Great!', product_id: product.id, user_id: user.id } }

    before do
      user.update(role: 'buyer')
    end

    it 'creates or updates a review and redirects with notice' do
      post save_review_product_path(product), params: { review: review_params }
      expect(response).to redirect_to(product)
      expect(flash[:notice]).to eq('Review was successfully saved.')
    end

    it 'renders show if review is invalid' do
      post save_review_product_path(product), params: { review: review_params.merge(rating: nil) }
      expect(response).to render_template(:show)
    end
  end

  describe 'DELETE /products/:id/delete_review' do
    let!(:product) { Product.create!(valid_attributes) }

    context 'when review exists' do
      let!(:review) { product.reviews.create!(user: user, rating: 4, comment: 'Nice!') }

      it 'deletes the review and redirects with notice' do
        delete delete_review_product_path(product)
        expect(response).to redirect_to(product)
        expect(flash[:notice]).to eq('Review was successfully deleted.')
      end
    end

    context 'when review does not exist' do
      it 'redirects with alert' do
        delete delete_review_product_path(product)
        expect(response).to redirect_to(product)
        expect(flash[:alert]).to eq('You have not reviewed this product yet.')
      end
    end
  end

  describe 'GET /products/sample_csv' do
    it 'responds with CSV format' do
      get sample_csv_products_path(format: :csv)
      expect(response.content_type).to include('text/csv')
      expect(response).to have_http_status(:ok)
    end

    it 'responds with not_acceptable for other formats' do
      get sample_csv_products_path(format: :json)
      expect(response).to have_http_status(:not_acceptable)
    end
  end

  describe 'GET /products/bulk_import' do
    it 'renders bulk import page' do
      get bulk_import_products_path
      expect(response).to be_successful
      expect(response).to render_template(:bulk_import)
    end
  end

  describe 'POST /products/bulk_import_action' do
    let(:csv_file) do
      Rack::Test::UploadedFile.new(
        StringIO.new("name,price,category_id\nLaptop,1000,#{category.id}"),
        'text/csv',
        original_filename: 'products.csv'
      )
    end

    it 'accepts valid CSV file and redirects with notice' do
      post bulk_import_action_products_path, params: { import_file: csv_file }
      expect(response).to redirect_to(bulk_import_products_path)
      expect(flash[:notice]).to eq('Import products is in processing.')
    end

    it 'rejects non-CSV file and redirects with alert' do
      txt_file = Rack::Test::UploadedFile.new(
        StringIO.new('not csv'),
        'text/plain',
        original_filename: 'products.txt'
      )
      post bulk_import_action_products_path, params: { import_file: txt_file }
      expect(response).to redirect_to(bulk_import_products_path)
      expect(flash[:alert]).to eq('Only CSV files are allowed for import.')
    end

    it 'rejects missing file and redirects with alert' do
      post bulk_import_action_products_path
      expect(response).to redirect_to(bulk_import_products_path)
      expect(flash[:alert]).to eq('Please upload a valid CSV file.')
    end
  end
end
