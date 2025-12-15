require 'rails_helper'

RSpec.describe 'Errors', type: :request do
  describe 'GET /*unmatched' do
    it 'should return 404 for non-existent route' do
      get '/non-existent-route'
      expect(response).to have_http_status(:not_found)
    end

    it 'should render HTML for HTML request' do
      get '/non-existent-route', headers: { 'Accept' => 'text/html' }
      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to include('text/html')
    end

    it 'should render JSON for JSON request' do
      get '/non-existent-route', headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Not Found')
    end
  end
end

