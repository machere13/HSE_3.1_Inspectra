require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  describe 'GET /weeks/:week_id/articles/:id' do
    it 'should get show' do
      week = Week.create!(number: 1, title: 'Test Week', description: 'Test')
      article = week.articles.create!(title: 'Test Article', body: 'Test body')
      
      get week_article_path(week, article)
      expect(response).to have_http_status(:success)
    end
  end
end

