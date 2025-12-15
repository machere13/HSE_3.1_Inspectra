require 'rails_helper'

RSpec.describe 'API::V1::ContentItems', type: :request do
  let!(:week) { Week.create!(number: 1, title: 'Test Week') }
  let!(:content_item) do
    week.content_items.create!(
      title: 'Test Content',
      kind: 'link',
      url: 'https://example.com'
    )
  end

  describe 'GET /api/v1/weeks/:week_id/content_items' do
    it 'should return content items for week' do
      get "/api/v1/weeks/#{week.id}/content_items"
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']).to be_an(Array)
      expect(json_response['data'].length).to eq(1)
      expect(json_response['data'].first['title']).to eq(content_item.title)
    end

    it 'should include article if present' do
      article = week.articles.create!(title: 'Test', body: 'Body')
      content_item.update_column(:article_id, article.id)
      get "/api/v1/weeks/#{week.id}/content_items"
      json_response = JSON.parse(response.body)
      if json_response['data'] && json_response['data'].first
        expect(json_response['data'].first['article']).to be_present
      end
    end

    it 'should return 404 for non-existent week' do
      get '/api/v1/weeks/999/content_items'
      expect(response).to have_http_status(:not_found)
    end
  end
end

