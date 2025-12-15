require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  describe 'GET /auth/login' do
    it 'should render login page' do
      get '/auth/login'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /auth/login' do
    context 'with new user' do
      it 'should register and redirect to verify' do
        expect {
          post '/auth/login', params: { email: 'new@example.com', password: 'password123' }
        }.to change(User, :count).by(1)
        
        expect(response).to redirect_to(verify_path(email: 'new@example.com'))
      end
    end

    context 'with existing user' do
      let!(:user) { User.create!(email: 'existing@example.com', password: 'password123') }

      it 'should login and redirect to verify' do
        post '/auth/login', params: { email: 'existing@example.com', password: 'password123' }
        expect(response).to redirect_to(verify_path(email: 'existing@example.com'))
      end

      it 'should show error for wrong password' do
        post '/auth/login', params: { email: 'existing@example.com', password: 'wrong' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'should require email and password' do
      post '/auth/login', params: {}
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /auth/verify' do
    it 'should render verify page' do
      get '/auth/verify'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /auth/verify' do
    let!(:user) do
      user = User.create!(email: 'test@example.com', password: 'password123')
      user.generate_verification_code!
      user
    end

    it 'should verify email with correct code' do
      post '/auth/verify', params: { email: user.email, code: user.verification_code }
      expect(response).to redirect_to(root_path)
    end

    it 'should show error for wrong code' do
      post '/auth/verify', params: { email: user.email, code: '000000' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /auth/resend' do
    let!(:user) { User.create!(email: 'test@example.com', password: 'password123', email_verified: false) }

    it 'should resend verification code' do
      post '/auth/resend', params: { email: user.email }
      expect(response).to redirect_to(verify_path(email: user.email))
    end
  end

  describe 'GET /auth/forgot' do
    it 'should render forgot password page' do
      get '/auth/forgot'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /auth/forgot' do
    let!(:user) { User.create!(email: 'test@example.com', password: 'password123', email_verified: true) }

    it 'should send reset password email' do
      post '/auth/forgot', params: { email: user.email }
      expect(response).to redirect_to(forgot_path)
    end
  end

  describe 'GET /auth/reset' do
    it 'should render reset password page' do
      get '/auth/reset', params: { token: 'test_token' }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /auth/reset' do
    let!(:user) do
      user = User.create!(email: 'test@example.com', password: 'password123', email_verified: true)
      user.generate_reset_password_token!
      user
    end

    it 'should reset password with valid token' do
      post '/auth/reset', params: {
        token: user.reset_password_token,
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
      expect(response).to redirect_to(root_path)
    end

    it 'should show error for invalid token' do
      post '/auth/reset', params: {
        token: 'invalid',
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

