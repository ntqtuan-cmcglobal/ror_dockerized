# frozen_string_literal: true

module Api
  class RevokeTokenService
    attr_reader :token, :errors

    def initialize(token)
      @token = token
    end

    def execute
      revoke_token token
    end

    def success?
      errors.nil?
    end

    private

    def revoke_token(token)
      access_token = Doorkeeper::AccessToken.find_by token: token
      if access_token
        access_token.revoke
      else
        @errors = I18n.t 'doorkeeper.errors.messages.invalid_token.unknown'
      end
    end
  end
end
