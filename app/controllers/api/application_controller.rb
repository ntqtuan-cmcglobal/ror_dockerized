module Api
  class ApplicationController < ActionController::API
    before_action :doorkeeper_authorize!
    before_action :current_user

    def doorkeeper_unauthorized_render_options(_error)
      { json: { errors: I18n.t('doorkeeper.errors.messages.unauthorized_client', uid: current_user&.id) } }
    end

    def current_user
      @current_user ||= User.find_by(id: doorkeeper_token.resource_owner_id) if doorkeeper_token
    end
  end
end
