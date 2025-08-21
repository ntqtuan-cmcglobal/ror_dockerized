require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :request do
  let(:user) { FactoryBot.create(:user, full_name: Faker::Name.name, email: Faker::Internet.email, password: 'password123', role: 'buyer') }
  let(:token_service) { instance_double(Api::GenerateTokenService) }
  let(:token) { 'sample_token' }

  describe 'POST /api/v1/login' do
    context 'with valid credentials' do
      it 'returns a token and status 200' do
        allow(User).to receive(:authenticate).and_return(user)
        allow(Api::GenerateTokenService).to receive(:new).with(user).and_return(token_service)
        allow(token_service).to receive(:call).and_return(token)

        post '/api/v1/login', params: { email: user.email, password: 'password123' }

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({ 'data' => token })
      end
    end

    context 'with invalid credentials' do
      it 'returns error and status 400' do
        allow(User).to receive(:authenticate).and_return(nil)

        post '/api/v1/login', params: { email: user.email, password: 'wrongpassword' }

        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors']).to eq(I18n.t('errors.api.sessions_controller.login.failed'))
      end
    end

    context 'with missing params' do
      it 'returns error and status 400' do
        post '/api/v1/login', params: { email: user.email }

        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors']).to eq(I18n.t('errors.api.sessions_controller.login.failed'))
      end
    end
  end

  describe 'DELETE /api/v1/logout' do
    let(:revoke_service) { instance_double(Api::RevokeTokenService, execute: true, success?: true, errors: []) }
    let(:doorkeeper_token) { double(token: 'access_token') }

    before do
      allow_any_instance_of(Api::V1::SessionsController).to receive(:doorkeeper_token).and_return(doorkeeper_token)
      allow(doorkeeper_token).to receive(:acceptable?).and_return(true)
      allow(doorkeeper_token).to receive(:resource_owner_id).and_return(user.id)
      allow(Api::RevokeTokenService).to receive(:new).with('access_token').and_return(revoke_service)
    end

    context 'when revoke is successful' do
      it 'returns status 200' do
        delete '/api/v1/logout'
        expect(response).to have_http_status(200)
        expect(response.body).to eq('{}')
      end
    end

    context 'when revoke fails' do
      before do
        allow(revoke_service).to receive(:success?).and_return(false)
        allow(revoke_service).to receive(:errors).and_return(['error'])
      end

      it 'returns error and status 400' do
        delete '/api/v1/logout'
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors']).to eq(['error'])
      end
    end
  end
end
