require 'rails_helper'

RSpec.describe Administration::UsersController, type: :request do
  original_api_key = ENV['MY_API_KEY']
  include Devise::Test::IntegrationHelpers
  let(:admin) { FactoryBot.create(:user, full_name: Faker::Name.name, role: 'admin', email: Faker::Internet.email, password: 'Password123!') }
  let(:user) { FactoryBot.create(:user, full_name: Faker::Name.name, role: 'buyer', email: Faker::Internet.email, password: 'Password123!') }

  before { sign_in admin }

  describe 'GET #index' do
    it 'renders the index template and lists users' do
      user # Ensure user is created before the request
      get administration_users_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.full_name)
    end
  end

  describe 'GET #show' do
    it 'renders the show template' do
      get administration_user_path(user)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.full_name)
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get new_administration_user_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    it 'creates a new user and redirects' do
      post administration_users_path,
           params: {
             user: {
               full_name: Faker::Name.name,
               email: Faker::Internet.email,
               # phone: Faker::PhoneNumber.phone_number,
               role: 'buyer',
               password: 'Password123!',
               password_confirmation: 'Password123!'
             }
           }
      expect(response).to redirect_to(administration_user_path(User.last))
      follow_redirect!
      expect(response.body).to include('User was successfully created.')
    end
    it 'renders new on failure' do
      post administration_users_path, params: {
        user: {
          full_name: '',
          email: '',
          role: '',
          password: '',
          password_confirmation: ''
        }
      }
      expect(response.body).to include('New User')
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      get edit_administration_user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH #update' do
    it 'updates the user and redirects' do
      patch administration_user_path(user), params: {
        user: {
          full_name: 'Updated Name',
          email: user.email,
          role: user.role
        }
      }
      expect(response).to redirect_to(administration_user_path(user))
      follow_redirect!
      expect(response.body).to include('User was successfully updated.')
    end
    it 'renders edit on failure' do
      patch administration_user_path(user), params: {
        user: {
          full_name: '',
          email: '',
          role: ''
        }
      }
      expect(response.body).to include('Edit User')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the user and redirects' do
      user_to_delete = FactoryBot.create(:user, full_name: Faker::Name.name, role: 'buyer',
                                                email: Faker::Internet.email, password: 'Password123!')
      delete administration_user_path(user_to_delete)
      File.open('tmp/response.html', 'w') { |f| f.write(response.body) }
      expect(response).to redirect_to(administration_users_path)
      follow_redirect!
      expect(response.body).to include('User was successfully deleted.')
    end
  end
end
