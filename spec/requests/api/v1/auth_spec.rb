require 'rails_helper'

RSpec.describe 'API::V1::Auth', type: :request do
  describe 'POST /api/v1/auth' do
    context 'with new user' do
      it 'should register new user' do
        expect {
          post '/api/v1/auth', params: { email: 'new@example.com', password: 'password123' }
        }.to change(User, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['data']['requires_verification']).to be true
      end

      it 'should send verification code' do
        expect {
          post '/api/v1/auth', params: { email: 'new@example.com', password: 'password123' }
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end

      it 'should return error for invalid email' do
        post '/api/v1/auth', params: { email: 'invalid', password: 'password123' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with existing user' do
      let!(:user) { User.create!(email: 'existing@example.com', password: 'password123') }

      it 'should login existing user' do
        post '/api/v1/auth', params: { email: 'existing@example.com', password: 'password123' }
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['requires_verification']).to be true
      end

      it 'should return error for wrong password' do
        post '/api/v1/auth', params: { email: 'existing@example.com', password: 'wrong' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'should require email and password' do
      post '/api/v1/auth', params: {}
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST /api/v1/auth/verify' do
    let!(:user) do
      user = User.create!(email: 'test@example.com', password: 'password123')
      user.generate_verification_code!
      user
    end

    it 'should verify email with correct code' do
      post '/api/v1/auth/verify', params: { email: user.email, code: user.verification_code }
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['token']).to be_present
      expect(json_response['data']['user']['email']).to eq(user.email)
    end

    it 'should return error for wrong code' do
      post '/api/v1/auth/verify', params: { email: user.email, code: '000000' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'should require email and code' do
      post '/api/v1/auth/verify', params: {}
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST /api/v1/auth/resend' do
    let!(:user) { User.create!(email: 'test@example.com', password: 'password123', email_verified: false) }

    it 'should resend verification code' do
      post '/api/v1/auth/resend', params: { email: user.email }
      expect(response).to have_http_status(:success)
    end

    it 'should not resend if email already verified' do
      user.update!(email_verified: true)
      post '/api/v1/auth/resend', params: { email: user.email }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'GET /api/v1/auth/me' do
    let(:user) { User.create!(email: 'test@example.com', password: 'password123', email_verified: true) }
    let(:token) { encode_test_jwt({ user_id: user.id }) }

    it 'should return current user' do
      get '/api/v1/auth/me', headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['user']['email']).to eq(user.email)
    end

    it 'should require authentication' do
      get '/api/v1/auth/me'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/auth/supported-domains' do
    it 'should return supported domains' do
      get '/api/v1/auth/supported-domains'
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['supported_domains']).to be_an(Array)
    end
  end

  describe 'POST /api/v1/auth/password/forgot' do
    let!(:user) { User.create!(email: 'test@example.com', password: 'password123', email_verified: true) }

    it 'should send reset password email' do
      post '/api/v1/auth/password/forgot', params: { email: user.email }
      expect(response).to have_http_status(:success)
    end

    it 'should require email' do
      post '/api/v1/auth/password/forgot', params: {}
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST /api/v1/auth/password/reset' do
    let!(:user) do
      user = User.create!(email: 'test@example.com', password: 'password123', email_verified: true)
      user.generate_reset_password_token!
      user
    end

    it 'should reset password with valid token' do
      post '/api/v1/auth/password/reset', params: {
        token: user.reset_password_token,
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['token']).to be_present
    end

    it 'should return error for invalid token' do
      post '/api/v1/auth/password/reset', params: {
        token: 'invalid',
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'should require all parameters' do
      post '/api/v1/auth/password/reset', params: {}
      expect(response).to have_http_status(:bad_request)
    end
  end
end

