require 'rails_helper'

RSpec.describe 'API::V0::Echo', type: :request do
  let(:user) { verified_user }

  before { load_all_interactives! }

  it 'returns 401 when anonymous' do
    get '/api/v0/echo', params: { seed: 1 }
    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns token via Bearer header' do
    get '/api/v0/echo', params: { seed: 1 }, headers: auth_headers_for(user)
    expect(response).to have_http_status(:success)
    body = JSON.parse(response.body)
    expect(body['data']['token']).to start_with('ECHO-')
    expect(body['data']['deprecated']).to be true
  end

  it 'returns token via cookie' do
    cookies[:token] = encode_test_jwt({ user_id: user.id })
    get '/api/v0/echo', params: { seed: 2 }
    expect(response).to have_http_status(:success)
  end

  it 'returns 404 for unknown seed' do
    get '/api/v0/echo', params: { seed: 999 }, headers: auth_headers_for(user)
    expect(response).to have_http_status(:not_found)
  end
end
