require 'rails_helper'

RSpec.describe 'API::V1::InteractiveProps', type: :request do
  let(:user) { verified_user }
  let(:headers) { auth_headers_for(user) }

  before { load_all_interactives! }

  def issue_session_for(interactive_key, user)
    interactive = Interactive.find_by!(key: interactive_key)
    attempt = user.interactive_attempts.find_or_create_by!(interactive: interactive)
    attempt.issue_session!
  end

  describe 'GET /api/v1/interactive_props/spy' do
    it 'returns 401 when anonymous' do
      get '/api/v1/interactive_props/spy'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns token JSON when authorized via Bearer header + valid session' do
      session = issue_session_for('dev_diving.network_spy', user)
      get '/api/v1/interactive_props/spy', params: { session: session }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['data']['token']).to be_present
      expect(body['data']['token']).to start_with('NET-')
    end

    it 'returns token JSON when authorized via cookie token (web fallback)' do
      session = issue_session_for('dev_diving.network_spy', user)
      cookies[:token] = encode_test_jwt({ user_id: user.id })
      get '/api/v1/interactive_props/spy', params: { session: session }
      expect(response).to have_http_status(:success)
    end

    it 'returns 403 without session token (no attempt open)' do
      get '/api/v1/interactive_props/spy', headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/v1/interactive_props/race/fast and /slow' do
    it 'fast returns token quickly with valid session' do
      session = issue_session_for('it_errors.data_race', user)
      t0 = Time.current
      get '/api/v1/interactive_props/race/fast', params: { session: session }, headers: headers
      elapsed = Time.current - t0
      expect(response).to have_http_status(:success)
      expect(elapsed).to be < 2
      body = JSON.parse(response.body)
      expect(body['data']['token']).to start_with('RACE-')
    end

    it 'slow always returns SLOW-DECOY (no session required)' do
      get '/api/v1/interactive_props/race/slow', headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['data']['token']).to eq('SLOW-DECOY')
    end
  end

  describe 'GET /api/v1/interactive_props/ie6_token' do
    it 'returns 403 with regular Chrome UA' do
      session = issue_session_for('legacy.ie6_hack', user)
      get '/api/v1/interactive_props/ie6_token',
          params: { session: session },
          headers: headers.merge('User-Agent' => 'Mozilla/5.0 (Chrome)')
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns token with IE6 UA + valid session' do
      session = issue_session_for('legacy.ie6_hack', user)
      ua = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'
      get '/api/v1/interactive_props/ie6_token',
          params: { session: session },
          headers: headers.merge('User-Agent' => ua)
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['data']['token']).to start_with('IE6-')
    end

    it 'returns 403 without session even with IE6 UA' do
      ua = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'
      get '/api/v1/interactive_props/ie6_token',
          headers: headers.merge('User-Agent' => ua)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/v1/interactive_props/profile/:id (IDOR)' do
    it 'returns regular user shape for id != 1 (no session needed)' do
      get '/api/v1/interactive_props/profile/2', headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['data']['user']['role']).to eq('user')
      expect(body['data']).not_to have_key('admin_token')
    end

    it 'returns admin_token for id=1 + valid session' do
      session = issue_session_for('it_security.unsecured_keys', user)
      get '/api/v1/interactive_props/profile/1', params: { session: session }, headers: headers
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['data']['user']['role']).to eq('admin')
      expect(body['data']['admin_token']).to start_with('ADMIN-')
    end
  end
end
