class PaymentsController < ApplicationController
    before_action :set_payment, only: [:show, :edit, :update, :destroy]

    def index
        @payments = Payment.all
    end

    def show
    end

    def new
        # if params[:order_id]
        #     @order = Order.find_by(id: params[:order_id])
        #     if @order
        #         @payments = @order.payments
        #         @payment = Payment.new(order_id: @order.id)
        #     else
        #         @payments = []
        #         @payment = Payment.new
        #         flash.now[:alert] = "Order not found."
        #     end
        # else
        #     @payments = []
        #     @payment = Payment.new
        # end
    end

    def create
        @payment = Payment.new(payment_params)
        if @payment.save
            redirect_to @payment, notice: 'Payment was successfully created.'
        else
            render :new
        end
    end

    def edit
    end

    def update
        if @payment.update(payment_params)
            redirect_to @payment, notice: 'Payment was successfully updated.'
        else
            render :edit
        end
    end

    def destroy
        @payment.destroy
        redirect_to payments_url, notice: 'Payment was successfully destroyed.'
    end

    private

    def set_payment
        @payment = Payment.find(params[:id])
    end

    def payment_params
        params.require(:payment).permit(:amount, :user_id, :status, :payment_method)
    end
end