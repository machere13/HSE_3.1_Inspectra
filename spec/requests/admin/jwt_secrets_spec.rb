require 'rails_helper'

RSpec.describe 'Admin::JwtSecrets', type: :request do
  let(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', email_verified: true, role: :admin) }
  let(:token) { encode_test_jwt({ user_id: admin_user.id }) }

  before do
    cookies[:token] = token
    Rails.cache.clear
  end

  describe 'GET /admin/jwt_secrets' do
    it 'should show jwt secrets page' do
      get '/admin/jwt_secrets'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /admin/jwt_secrets/rotate' do
    it 'should rotate jwt secret' do
      expect {
        post '/admin/jwt_secrets/rotate'
      }.to change(JwtSecretRotation, :count).by(1)
      expect(response).to redirect_to(admin_jwt_secrets_path)
    end
  end

  describe 'GET /admin/jwt_secrets/stats' do
    it 'should return stats as JSON' do
      get '/admin/jwt_secrets/stats'
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('last_rotation')
    end
  end
end

