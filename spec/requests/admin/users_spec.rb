require 'rails_helper'

RSpec.describe 'Admin::Users', type: :request do
  let(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', email_verified: true, role: :admin) }
  let(:token) { encode_test_jwt({ user_id: admin_user.id }) }

  before do
    cookies[:token] = token
  end

  describe 'GET /admin/users' do
    it 'should list users' do
      User.create!(email: 'user@example.com', password: 'password123')
      get '/admin/users'
      expect(response).to have_http_status(:success)
    end

    it 'should filter by role' do
      User.create!(email: 'moderator@example.com', password: 'password123', role: :moderator)
      get '/admin/users', params: { role: 'moderator' }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /admin/users/:id' do
    let(:user) { User.create!(email: 'user@example.com', password: 'password123') }

    it 'should show user' do
      get "/admin/users/#{user.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /admin/users/:id' do
    let(:user) { User.create!(email: 'user@example.com', password: 'password123') }

    it 'should update user' do
      patch "/admin/users/#{user.id}", params: { user: { role: 'moderator' } }
      expect(response).to redirect_to(admin_user_path(user))
      expect(user.reload.moderator?).to be true
    end
  end
end

