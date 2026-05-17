require 'rails_helper'

RSpec.describe 'API::V0::Echo', type: :request do
  let(:user) { verified_user }

  before { load_all_interactives! }

  def issue_echo_session(user)
    interactive = Interactive.find_by!(key: 'legacy.echo_of_past')
    user.interactive_attempts.find_or_create_by!(interactive: interactive).issue_session!
  end

  it 'returns 401 when anonymous' do
    get '/api/v0/echo'
    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns token via Bearer header + valid session' do
    session = issue_echo_session(user)
    get '/api/v0/echo', params: { session: session }, headers: auth_headers_for(user)
    expect(response).to have_http_status(:success)
    body = JSON.parse(response.body)
    expect(body['data']['token']).to start_with('ECHO-')
    expect(body['data']['deprecated']).to be true
  end

  it 'returns token via cookie + valid session' do
    session = issue_echo_session(user)
    cookies[:token] = encode_test_jwt({ user_id: user.id })
    get '/api/v0/echo', params: { session: session }
    expect(response).to have_http_status(:success)
  end

  it 'returns 403 without session' do
    get '/api/v0/echo', headers: auth_headers_for(user)
    expect(response).to have_http_status(:forbidden)
  end
end
