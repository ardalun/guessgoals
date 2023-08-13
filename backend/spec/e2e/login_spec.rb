require 'rails_helper'

RSpec.feature "Login Feature", type: :feature do

  it 'does not log me in with a wrong password' do
    create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!')
    visit "#{BASE_URL}/login"
    fill_in 'email', with: 'test@test.com'
    fill_in 'password', with: 'wrong'
    click_button 'Log in'
    wait_for_ajax
    expect(page).to have_content('Invalid email and password combination')
  end

  it 'does not log me in with a inactive account' do
    create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!', active: false)
    visit "#{BASE_URL}/login"
    fill_in 'email', with: 'test@test.com'
    fill_in 'password', with: 'abcdefghA1!'
    click_button 'Log in'
    wait_for_ajax
    expect(page).to have_content('Your account is not yet activated')
  end

  it 'logs me in' do
    create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!')
    visit "#{BASE_URL}/login"
    id_token_cookie = Capybara.current_session.driver.browser.manage.cookie_named('id_token') rescue nil
    expect(id_token_cookie).to be_nil
    fill_in 'email', with: 'test@test.com'
    fill_in 'password', with: 'abcdefghA1!'
    click_button 'Log in'
    wait_for_ajax
    id_token_cookie = Capybara.current_session.driver.browser.manage.cookie_named('id_token')
    expect(id_token_cookie).to be_nil
  end
  
end
