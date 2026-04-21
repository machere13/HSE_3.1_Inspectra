require 'rails_helper'

RSpec.describe 'Admin::MediaSubscriptions', type: :request do
  let(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', email_verified: true, role: :admin) }
  let(:token) { encode_test_jwt({ user_id: admin_user.id }) }

  before do
    cookies[:token] = token
  end

  describe 'GET /admin/media_subscriptions' do
    it 'requires admin access' do
      regular_user = User.create!(email: 'user@example.com', password: 'password123', email_verified: true)
      cookies[:token] = encode_test_jwt({ user_id: regular_user.id })

      get '/admin/media_subscriptions'

      expect(response).to redirect_to(auth_path)
    end

    it 'shows subscriptions for admin' do
      MediaSubscription.create!(email: 'reader@example.com')

      get '/admin/media_subscriptions'

      expect(response).to have_http_status(:success)
      expect(response.body).to include('reader@example.com')
    end
  end
end
