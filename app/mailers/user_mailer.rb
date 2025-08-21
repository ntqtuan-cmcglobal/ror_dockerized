class UserMailer < ActionMailer::Base
  default from: 'from@example.com'

  def payment_success(user, payment)
    @user = user
    @payment = payment
    mail(to: @user.email, subject: 'Payment Successful')
  end
end
