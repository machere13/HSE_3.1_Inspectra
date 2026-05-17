require 'rails_helper'

RSpec.describe 'API::V1::InteractiveProps', type: :request do
  let(:user) { verified_user }
  let(:headers) { auth_headers_for(user) }

  before { load_all_interactives! }

  describe 'GET /api/v1/interactive_props/spy' do
    it 'returns 401 when anonymous' do
      get '/api/v1/interactive_props/spy', params: { seed: 1 }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns token JSON when authorized via Bearer header' do
      get '/api/v1/interactive_props/spy', params: { seed: 1 }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['data']['token']).to be_present
    end

    it 'returns token JSON when authorized via cookie token (web fallback)' do
      cookies[:token] = encode_test_jwt({ user_id: user.id })
      get '/api/v1/interactive_props/spy', params: { seed: 1 }
      expect(response).to have_http_status(:success)
    end

    it 'returns 404 for non-existent seed' do
      get '/api/v1/interactive_props/spy', params: { seed: 999 }, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/interactive_props/race/fast and /slow' do
    it 'fast returns token quickly' do
      t0 = Time.current
      get '/api/v1/interactive_props/race/fast', params: { seed: 1 }, headers: headers
      elapsed = Time.current - t0
      expect(response).to have_http_status(:success)
      expect(elapsed).to be < 2
      body = JSON.parse(response.body)
      expect(body['data']['token']).to start_with('RACE-')
    end

    it 'slow always returns SLOW-DECOY' do
      get '/api/v1/interactive_props/race/slow', params: { seed: 1 }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['data']['token']).to eq('SLOW-DECOY')
    end
  end

  describe 'GET /api/v1/interactive_props/ie6_token' do
    it 'returns 403 with regular Chrome UA' do
      get '/api/v1/interactive_props/ie6_token',
          params: { seed: 1 },
          headers: headers.merge('User-Agent' => 'Mozilla/5.0 (Chrome)')
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns token with IE6 UA' do
      ua = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'
      get '/api/v1/interactive_props/ie6_token',
          params: { seed: 1 },
          headers: headers.merge('User-Agent' => ua)
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['data']['token']).to start_with('IE6-')
    end

    it 'returns 404 when seed missing' do
      ua = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'
      get '/api/v1/interactive_props/ie6_token',
          params: { seed: 999 },
          headers: headers.merge('User-Agent' => ua)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/interactive_props/profile/:id (IDOR)' do
    it 'returns regular user shape for id != 1' do
      get '/api/v1/interactive_props/profile/2', params: { seed: 1 }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['data']['user']['role']).to eq('user')
      expect(body['data']).not_to have_key('admin_token')
    end

    it 'returns admin_token for id=1' do
      get '/api/v1/interactive_props/profile/1', params: { seed: 1 }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['data']['user']['role']).to eq('admin')
      expect(body['data']['admin_token']).to start_with('ADMIN-TOKEN-')
    end
  end
end
