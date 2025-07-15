require 'rails_helper'
require 'faker'

RSpec.feature 'User Authentication', type: :feature do
  let(:user) do
    User.create(
      full_name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      password: 'password',
      role: 'buyer'
    )
  end

  scenario 'User signs in with valid credentials' do
    visit new_user_session_path
    find_field('Email').set(user.email)
    find_field('Password').set('password')
    click_button 'Login'

    expect(page).to have_content('Signed in successfully')
  end

  scenario 'User fails to sign in with invalid credentials' do
    visit new_user_session_path
    find_field('Email').set(user.email)
    find_field('Password').set('wrongpassword')
    click_button 'Login'

    expect(page).to have_content('Invalid Email or password')
  end

  scenario 'User signs out successfully' do
    visit new_user_session_path
    find_field('Email').set(user.email)
    find_field('Password').set('password')
    click_button 'Login'
    click_link 'Logout'

    expect(page).to have_content('Signed out successfully')
  end

  scenario 'User cannot access protected page without signing in' do
    visit products_path

    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content('You need to sign in or sign up before continuing')
  end
end
