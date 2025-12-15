require 'rails_helper'

RSpec.describe 'API::V1::Articles', type: :request do
  let!(:week) { Week.create!(number: 1, title: 'Test Week') }
  let!(:article) { week.articles.create!(title: 'Test Article', body: 'Test body') }

  describe 'GET /api/v1/weeks/:week_id/articles' do
    it 'should return articles for week' do
      get "/api/v1/weeks/#{week.id}/articles"
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to eq(1)
      expect(json_response['data'].first['title']).to eq(article.title)
    end

    it 'should return 404 for non-existent week' do
      get '/api/v1/weeks/999/articles'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/weeks/:week_id/articles/:id' do
    it 'should return article' do
      get "/api/v1/weeks/#{week.id}/articles/#{article.id}"
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(article.id)
    end

    it 'should return 404 for non-existent article' do
      get "/api/v1/weeks/#{week.id}/articles/999"
      expect(response).to have_http_status(:not_found)
    end
  end
end

