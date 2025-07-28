class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[show edit update destroy]

  def index
    @payments = Payment.where(order_id: params[:order_id])
  end

  def show
    authorize @payment
    # Ensure the user is authorized to view this payment
    redirect_to root_path, alert: 'Payment not found.' and return unless @payment

    # If the user is not an admin, check if they are the owner of the payment
    return if current_user.admin? || @payment.user_id == current_user.id

    redirect_to root_path, alert: 'You are not authorized to view this payment.'
    nil
  end

  def new
    return unless params[:order_id]

    @order = Order.find_by(id: params[:order_id])
    @payment = Payment.new(order_id: @order.id)
    authorize @payment
    redirect_to root_path, alert: 'Order not found.' and return unless @order

    # Ensure the user is authorized to create a payment for this order
    authorize @payment, :new?
  end

  def create
    @payment = Payment.new(payment_params)

    @payment.result = PaymentResult::SUCCESS if @payment.payment_method == 'bank_transfer'

    if @payment.save
      # Update order status to paid
      @order = Order.find(@payment.order_id)
      @order.update(status: OrderStatus::PAID) if @order.status == OrderStatus::UNPAID
      # Optionally, you can redirect to the order page or payment confirmation
      redirect_to @order, notice: 'Payment was successfully created and order status updated.'
    else
      render :new
    end
  end

  def edit; end

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
    params.require(:payment).permit(:order_id, :result, :payment_method)
  end
end
