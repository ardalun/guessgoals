require 'rails_helper'

RSpec.feature "Signup Feature", type: :feature do

  it 'validates presence of username' do
    visit "#{BASE_URL}/signup"
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Username can\'t be blank')
  end

  it 'validates length of username' do
    visit "#{BASE_URL}/signup"
    
    fill_in 'username', with: 'ab'
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Username is too short')

    fill_in 'username', with: Array.new(17, 'a').join
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Username is too long')
  end

  it 'validates uniqueness of username' do
    create(:user, username: 'test')
    visit "#{BASE_URL}/signup"
    fill_in 'username', with: 'test'
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Username has already been taken')
  end

  it 'validates presence of email' do
    visit "#{BASE_URL}/signup"
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Email can\'t be blank')
  end

  it 'validates length of email' do
    visit "#{BASE_URL}/signup"
    
    fill_in 'email', with: 'a@b.c'
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Email is too short')

    fill_in 'email', with: "#{Array.new(128, 'a').join}@gmail.com"
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Email is too long')
  end

  it 'validates format of email' do
    visit "#{BASE_URL}/signup"
    fill_in 'email', with: 'testthisinvalidemail'
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Email is invalid')
  end

  it 'validates uniqueness of email' do
    create(:user, email: 'test@test.com')
    visit "#{BASE_URL}/signup"
    fill_in 'email', with: 'test@test.com'
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Email has already been taken')
  end

  it 'validates presence of password' do
    visit "#{BASE_URL}/signup"
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Password can\'t be blank')
  end

  it 'validates length of password' do
    visit "#{BASE_URL}/signup"
    fill_in 'password', with: '1234567'
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Password is too short')
  end

  it 'validates strongness password' do
    visit "#{BASE_URL}/signup"
    fill_in 'password', with: 'abcdefgh'
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Password must contain at least one uppercase letter, one lowercase letter, one number and one special character')
  end

  it 'signs me up' do
    visit "#{BASE_URL}/signup"
    fill_in 'username', with: 'test'
    fill_in 'email',    with: 'test@gmail.com'
    fill_in 'password', with: '!bcdef9H'
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Check Your Email')
    user = User.find_by(email: 'test@gmail.com')
    expect(user).not_to be_nil
  end

  it 'signs me up with a downcased email' do
    visit "#{BASE_URL}/signup"
    fill_in 'username', with: 'test'
    fill_in 'email',    with: 'TEST@gmail.com'
    fill_in 'password', with: '!bcdef9H'
    click_button 'Sign up'
    wait_for_ajax
    expect(page).to have_content('Check Your Email')
    downcase_user = User.find_by(email: 'test@gmail.com')
    upcase_user = User.find_by(email: 'TEST@gmail.com')
    expect(downcase_user).not_to be_nil
    expect(upcase_user).to be_nil
  end

  it 'validates activation token' do
    create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!')
    visit "#{BASE_URL}/activate/wrongtoken"
    expect(page).to have_content('Invalid Token')
  end

  it 'activates my account with valid link' do
    user = create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!', active: false)
    visit user.activation_link
    expect(page).to have_content('Thank You')
  end
  
  it 'expires valid activation links after first use' do
    user = create(:user, username: 'test', email: 'test@test.com', password: 'abcdefghA1!', active: false)
    link = user.activation_link 
    visit link
    expect(page).to have_content('Thank You')
    visit link
    expect(page).to have_content('Invalid Token')
  end
  

end
