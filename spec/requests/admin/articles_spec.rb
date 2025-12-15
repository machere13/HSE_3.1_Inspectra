require 'rails_helper'

RSpec.describe 'Admin::Articles', type: :request do
  let(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', email_verified: true, role: :admin) }
  let(:week) { Week.create!(number: 1, title: 'Test Week') }
  let(:token) { encode_test_jwt({ user_id: admin_user.id }) }

  before do
    cookies[:token] = token
  end

  describe 'GET /admin/weeks/:week_id/articles' do
    it 'should list articles' do
      week.articles.create!(title: 'Test Article', body: 'Body')
      get "/admin/weeks/#{week.id}/articles"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /admin/weeks/:week_id/articles' do
    it 'should create article' do
      expect {
        post "/admin/weeks/#{week.id}/articles", params: {
          article: {
            title: 'New Article',
            body: 'Body'
          }
        }
      }.to change(Article, :count).by(1)
    end
  end

  describe 'PATCH /admin/weeks/:week_id/articles/:id' do
    let(:article) { week.articles.create!(title: 'Test Article', body: 'Body') }

    it 'should update article' do
      patch "/admin/weeks/#{week.id}/articles/#{article.id}", params: {
        article: { title: 'Updated Title' }
      }
      expect(response).to redirect_to(admin_week_article_path(week, article))
      expect(article.reload.title).to eq('Updated Title')
    end
  end

  describe 'DELETE /admin/weeks/:week_id/articles/:id' do
    let!(:article) { week.articles.create!(title: 'Test Article', body: 'Body') }

    it 'should delete article' do
      expect {
        delete "/admin/weeks/#{week.id}/articles/#{article.id}"
      }.to change(Article, :count).by(-1)
    end
  end
end

