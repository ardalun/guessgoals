require 'rails_helper'

RSpec.feature "Password Recovery Feature", type: :feature do

  it 'says password link sent regardless of email being valid or not' do
    create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!')
    visit "#{BASE_URL}/forgot-password"
    fill_in 'email', with: 'test@test.com'
    click_button 'Send Reset Link'
    wait_for_ajax
    expect(page).to have_content('Check Your Email')

    visit "#{BASE_URL}/forgot-password"
    fill_in 'email', with: 'wrong@test.com'
    click_button 'Send Reset Link'
    wait_for_ajax
    expect(page).to have_content('Check Your Email')
  end

  it 'sets a pass_reset_token on user' do 
    user = create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!')
    expect(user.pass_reset_token).to be_nil 

    visit "#{BASE_URL}/forgot-password"
    fill_in 'email', with: 'test@test.com'
    click_button 'Send Reset Link'
    wait_for_ajax
    expect(page).to have_content('Check Your Email')
    user.reload
    expect(user.pass_reset_token).not_to be_nil 
  end

  it 'validates presence of password' do
    user = create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!')
    user.set_new_pass_reset_token!
    visit user.pass_reset_link
    click_button 'Reset Password'
    wait_for_ajax
    expect(page).to have_content('Password can\'t be blank')
  end
  
  it 'validates length of password' do 
    user = create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!')
    user.set_new_pass_reset_token!
    visit user.pass_reset_link
    fill_in 'password', with: '1234567'
    click_button 'Reset Password'
    wait_for_ajax
    expect(page).to have_content('Password is too short')
  end
  
  it 'validates strongness of password' do 
    user = create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!')
    user.set_new_pass_reset_token!
    visit user.pass_reset_link
    fill_in 'password', with: 'abcdefgh'
    click_button 'Reset Password'
    wait_for_ajax
    expect(page).to have_content('Password must contain at least one uppercase letter, one lowercase letter, one number and one special character')
  end

  it 'validates password and password repeat match' do 
    user = create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!')
    user.set_new_pass_reset_token!
    visit user.pass_reset_link
    fill_in 'password', with: 'abcdefgh'
    fill_in 'password_repeat', with: 'abcdefg'
    click_button 'Reset Password'
    wait_for_ajax
    expect(page).to have_content('Password Repeat does not match')
  end

  it 'resets my password' do 
    user = create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!')
    user.set_new_pass_reset_token!
    visit user.pass_reset_link
    fill_in 'password', with: 'abcdefgh3#K'
    fill_in 'password_repeat', with: 'abcdefgh3#K'
    click_button 'Reset Password'
    wait_for_ajax
    expect(page).to have_content('All Set')
  end

  it 'expires password reset link after first use' do 
    user = create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!')
    user.set_new_pass_reset_token!
    link = user.pass_reset_link
    visit link
    fill_in 'password', with: 'abcdefgh3#K'
    fill_in 'password_repeat', with: 'abcdefgh3#K'
    click_button 'Reset Password'
    wait_for_ajax
    visit link
    expect(page).to have_content('Invalid Token')
  end
  
end
