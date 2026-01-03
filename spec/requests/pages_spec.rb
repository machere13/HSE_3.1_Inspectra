require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /' do
    it 'should get home' do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it 'should show current week' do
      week = Week.create!(
        number: 1,
        title: 'Current Week',
        published_at: 1.day.ago,
        expires_at: 1.day.from_now
      )
      get root_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /about' do
    it 'should get about' do
      get about_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /profile' do
    context 'without authentication' do
      it 'should require authentication' do
        get profile_path
        expect(response).to redirect_to(auth_path)
      end
    end

    context 'with authentication' do
      let(:user) { User.create!(email: 'test@example.com', password: 'password123', email_verified: true) }
      let(:token) { encode_test_jwt({ user_id: user.id }) }

      before do
        cookies[:token] = token
      end

      it 'should show profile for authenticated user' do
        get profile_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'PATCH /profile/select_title' do
    let(:user) { User.create!(email: 'test@example.com', password: 'password123', email_verified: true) }
    let(:title) { Title.create!(name: 'Test Title') }
    let(:token) { encode_test_jwt({ user_id: user.id }) }

    before do
      cookies[:token] = token
      user.user_titles.create!(title: title, earned_at: Time.current)
    end

    it 'should select title' do
      patch select_title_path, params: { title_id: title.id }
      expect(response).to redirect_to(profile_path)
      expect(user.reload.current_title).to eq(title)
    end
  end

  describe 'PATCH /profile/update_name' do
    let(:user) { User.create!(email: 'test@example.com', password: 'password123', email_verified: true) }
    let(:token) { encode_test_jwt({ user_id: user.id }) }

    before do
      cookies[:token] = token
    end

    it 'should update name' do
      patch update_name_path, params: { name: 'New Name' }
      expect(response).to redirect_to(profile_path)
      expect(user.reload.name).to eq('New Name')
    end
  end

end
