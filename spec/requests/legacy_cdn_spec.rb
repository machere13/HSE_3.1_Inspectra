require 'rails_helper'

RSpec.describe 'LegacyCdn', type: :request do
  it 'returns JS stub for legitimate filename' do
    get '/legacy/cdn/jquery-1.4.2.js'
    expect(response).to have_http_status(:success)
    expect(response.content_type).to include('application/javascript')
    expect(response.body).to include('jquery-1.4.2.js')
  end

  it 'works for any filename matching the safe pattern' do
    get '/legacy/cdn/lodash-0.12.0.js'
    expect(response).to have_http_status(:success)
    expect(response.body).to include('lodash-0.12.0.js')
  end

  it 'rejects filename with path traversal' do
    get '/legacy/cdn/..%2Fetc%2Fpasswd'
    expect(response).to have_http_status(:not_found)
  end

  it 'rejects filename with unsafe characters' do
    get '/legacy/cdn/script;rm'
    expect(response).to have_http_status(:not_found)
  end
end
