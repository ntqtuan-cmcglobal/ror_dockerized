class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payment, only: %i[show edit update destroy]

  def index
    @payments = Payment.where(order_id: params[:order_id])
                       .page(params[:page])
                       .recent
    @payments.each do |payment|
      if payment.stripe_session_id && payment.order.status == OrderStatus::UNPAID
        payment.stripe_checkout_url = Stripe::Checkout::Session.retrieve(payment.stripe_session_id).url
      end
    end
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

    if @payment.save
      ActiveRecord::Base.transaction do
        if @payment.payment_method == 'stripe'
          stripe_line_items = @payment.order.order_items.map do |item|
            {
              price_data: {
                currency: 'usd',
                product_data: {
                  name: item.product.name,
                  images: [url_for(item.product.digital_asset) || url_for(item.product.video_thumbnail)]
                },
                unit_amount: item.product.price.to_i * 100
              },
              quantity: 1
            }
          end

          session = Stripe::Checkout::Session.create(
            line_items: stripe_line_items,
            mode: 'payment',
            customer_email: current_user.email,
            success_url: payment_check_stripe_payment_url(@payment.id),
            cancel_url: payment_check_stripe_payment_url(@payment.id)
          )

          @payment.update!(stripe_session_id: session.id)
        elsif @payment.payment_method == 'bank_transfer'
          @payment.update!(result: PaymentResult::SUCCESS)
        end
      end

      redirect_to order_payments_url(@payment.order), notice: 'Payment created.'
    else
      render :new
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    @payment.update(result: PaymentResult::ERROR)
    redirect_to order_payments_url(@payment.order)
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

  def check_stripe_payment
    @payment = Payment.find(params[:payment_id])
    if @payment.payment_method == 'stripe'
      session = Stripe::Checkout::Session.retrieve(@payment.stripe_session_id)
      if session.payment_status == 'paid'
        @payment.update(result: PaymentResult::SUCCESS)
        redirect_to order_payments_url(@payment.order), notice: 'Payment was successful.'
      else
        redirect_to order_payments_url(@payment.order), alert: 'Payment not completed.'
      end
    else
      redirect_to order_payments_url(@payment.order), alert: 'Payment method is not Stripe.'
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    @payment.update(result: PaymentResult::ERROR)
    redirect_to order_payments_url(@payment.order)
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def payment_params
    params.require(:payment).permit(:order_id, :result, :payment_method)
  end
end
