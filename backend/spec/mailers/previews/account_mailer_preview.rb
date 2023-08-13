class AccountMailerPreview < ActionMailer::Preview

  def activate_your_account
    AccountMailer.activate_your_account(FactoryBot.create(:user).id)
  end

  def reset_your_password
    AccountMailer.reset_your_password(FactoryBot.create(:user).id)
  end

end
