# frozen_string_literal: true

module Api
  class GenerateTokenService
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def call
      generate_token user
    end

    private

    def generate_token(user)
      application = Doorkeeper::Application.first

      raise 'No Doorkeeper application found' unless application

      access_token = Doorkeeper::AccessToken.create! resource_owner_id: user.id,
                                                     application_id: application.id,
                                                     expires_in: Doorkeeper.configuration.access_token_expires_in, use_refresh_token: true
      token_info = Doorkeeper::OAuth::TokenResponse.new(access_token).body
                                                   .merge id: user.id, email: user.email
      created_at = token_info['created_at']
      token_info['created_at'] = Time.zone.at(created_at).iso8601
      token_info.merge expires_on: Time.zone.at(created_at + token_info['expires_in']).iso8601
    end
  end
end
