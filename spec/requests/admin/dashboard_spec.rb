require 'rails_helper'

RSpec.describe 'Admin::Dashboard', type: :request do
  let(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', email_verified: true, role: :admin) }
  let(:token) { encode_test_jwt({ user_id: admin_user.id }) }

  before do
    cookies[:token] = token
  end

  describe 'GET /admin/dashboard' do
    it 'should require admin access' do
      regular_user = User.create!(email: 'user@example.com', password: 'password123', email_verified: true)
      cookies[:token] = encode_test_jwt({ user_id: regular_user.id })
      get '/admin/dashboard'
      expect(response).to redirect_to(auth_path)
    end

    it 'should show dashboard for admin' do
      get '/admin/dashboard'
      expect(response).to have_http_status(:success)
    end

    it 'should show statistics' do
      User.create!(email: 'user1@example.com', password: 'password123')
      get '/admin/dashboard'
      expect(response).to have_http_status(:success)
    end
  end
end

