require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /' do
    it 'should get home' do
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
end

