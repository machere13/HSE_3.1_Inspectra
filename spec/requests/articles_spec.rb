require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  describe 'GET /days/:day_id/articles/:id' do
    it 'should get show' do
      day = Day.create!(number: 1, title: 'Test Day', description: 'Test')
      article = day.articles.create!(title: 'Test Article', body: 'Test body')
      
      get day_article_path(day, article)
      expect(response).to have_http_status(:success)
    end
  end
end

