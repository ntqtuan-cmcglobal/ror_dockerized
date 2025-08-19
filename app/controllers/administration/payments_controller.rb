module Administration
  class PaymentsController < ApplicationController
    def index
      q_params = params[:q] || {}
      @q = Payment.ransack(q_params.except(:order_user_full_name_cont))
      payments_scope = @q.result.recent

      if params.dig(:q, :order_user_full_name_cont).present?
        full_name = params[:q][:order_user_full_name_cont]
        payments_scope = payments_scope.joins(order: :user).where('users.full_name ILIKE ?', "%#{ActiveRecord::Base.sanitize_sql_like(full_name)}%")
      end

      @payments = payments_scope.page(params[:page])
    end
  end
end
