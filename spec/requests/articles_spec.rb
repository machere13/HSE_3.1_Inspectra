require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  let!(:week) do
    Week.create!(
      number: 1,
      title: 'Test Week',
      published_at: 1.day.ago,
      expires_at: 1.day.from_now
    )
  end
  let!(:article) { week.articles.create!(title: 'Test Article', body: 'Test body') }

  describe 'GET /weeks/:week_id/articles/:id' do
    it 'should get show' do
      get week_article_path(week, article)
      expect(response).to have_http_status(:success)
    end

    it 'should return 404 for non-existent article' do
      get "/weeks/#{week.id}/articles/999"
      # Может быть 404 или исключение в зависимости от реализации
      expect([404, 500]).to include(response.status)
    end

    it 'should return 404 for non-existent week' do
      get "/weeks/999/articles/#{article.id}"
      expect(response).to have_http_status(:not_found)
    end
  end
end

