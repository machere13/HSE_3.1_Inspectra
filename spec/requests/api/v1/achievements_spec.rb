require 'rails_helper'

RSpec.describe 'API::V1::Achievements', type: :request do
  before do
    UserAchievement.delete_all
    Achievement.delete_all
  end
  let(:user) { User.create!(email: "test@example.com", password: "password123", email_verified: true) }
  let(:token) { encode_test_jwt({ user_id: user.id }) }
  let(:achievement) do
    Achievement.create!(
      name: "Тестовое достижение",
      description: "Описание тестового достижения",
      category: "general",
      progress_type: "total_interactives",
      progress_target: 10
    )
  end
  let!(:user_achievement) do
    UserAchievement.create!(
      user: user,
      achievement: achievement,
      progress: 5
    )
  end

  describe 'GET /api/v1/achievements' do
    it 'should get all achievements' do
      get '/api/v1/achievements'
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      data = json_response['data']
      expect(data.length).to eq(1)
      expect(data.first['name']).to eq(achievement.name)
    end
  end

  describe 'GET /api/v1/achievements/my' do
    it 'should get user achievements' do
      get '/api/v1/achievements/my', headers: { 'Authorization' => "Bearer #{token}" }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)['data']
      expect(json_response).to have_key('completed')
      expect(json_response).to have_key('in_progress')
      expect(json_response['in_progress'].length).to eq(1)
    end

    it 'should require authentication for user achievements' do
      get '/api/v1/achievements/my'
      
      expect(response).to have_http_status(:unauthorized)
    end

    it 'should return 401 for invalid token' do
      get '/api/v1/achievements/my', headers: { 'Authorization' => 'Bearer invalid_token' }
      
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/achievements/by_category' do
    it 'should get achievements by category' do
      get '/api/v1/achievements/by_category', params: { category: 'general' }
      
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)['data']
      expect(data.length).to eq(1)
      expect(data.first['category']).to eq('general')
    end

    it 'should return 400 for invalid category' do
      get '/api/v1/achievements/by_category', params: { category: 'invalid' }
      
      expect(response).to have_http_status(:bad_request)
    end
  end
end

