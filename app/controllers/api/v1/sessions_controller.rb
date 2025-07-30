# frozen_string_literal: true

module Api
  module V1
    class SessionsController < Api::ApplicationController
      skip_before_action :doorkeeper_authorize!, only: :create

      def create
        user = User.authenticate({ email: params[:email], password: params[:password] })
        if user
          render json: { data: Api::GenerateTokenService.new(user).call }, status: 200
        else
          render json: { errors: I18n.t('errors.api.sessions_controller.login.failed') }, status: 400
        end
      rescue ActionController::ParameterMissing
        render json: { errors: I18n.t('errors.api.sessions_controller.login.missing_params') }, status: 400
      end

      def destroy
        revoke_token_service = Api::RevokeTokenService.new doorkeeper_token.token
        revoke_token_service.execute
        if revoke_token_service.success?
          render json: {}, status: 200 and return
        else
          render json: { errors: revoke_token_service.errors }, status: 400 and return
        end
      end

      private

      def users_params
        params.require(:email)
        params.require(:password)
        params.permit(:email, :password)
      end
    end
  end
end
