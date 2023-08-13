class AccountMailer < ApplicationMailer
  default from: 'GuessGoals <support@mail.guessgoals.com>'
  layout 'mailer'

  def activate_your_account(user_id)
    user = User.find_by(id: user_id)
    @link = user.activation_link
    @to   = user.email
    mail(to: @to, subject: 'Activates Your Account')
  end

  def reset_your_password(user_id)
    user = User.find_by(id: user_id)
    @link = user.pass_reset_link
    @to   = user.email
    mail(to: @to, subject: 'Reset Your Password')
  end
end