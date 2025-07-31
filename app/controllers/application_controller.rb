class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include CartsHelper

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protect_from_forgery

  private

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referrer || root_path)
  end

  def after_sign_in_path_for(resource)
    init_cart if resource.buyer?
    super
  end

  before_action :rack_mini_profiler_authorize_request

  def rack_mini_profiler_authorize_request
    environments = Rails.application.config.rack_mini_profiler_environments
    return unless Rails.env.in? environments

    Rack::MiniProfiler.authorize_request
  end
end
