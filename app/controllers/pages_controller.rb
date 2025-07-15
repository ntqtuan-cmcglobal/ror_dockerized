class PagesController < ApplicationController
  # before_action :authenticate_user!, only: %i[index new]

  def index
    @products = if user_signed_in?
                  Product.limit(6)
                else
                  redirect_to new_user_session_path and return
                end
  end

  def new; end
end
