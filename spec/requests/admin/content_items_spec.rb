require 'rails_helper'

RSpec.describe 'Admin::ContentItems', type: :request do
  let(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', email_verified: true, role: :admin) }
  let(:week) { Week.create!(number: 1, title: 'Test Week') }
  let(:token) { encode_test_jwt({ user_id: admin_user.id }) }

  before do
    cookies[:token] = token
  end

  describe 'GET /admin/weeks/:week_id/content_items' do
    it 'should list content items' do
      week.content_items.create!(
        title: 'Test',
        kind: 'link',
        url: 'https://example.com'
      )
      get "/admin/weeks/#{week.id}/content_items"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /admin/weeks/:week_id/content_items' do
    it 'should create content item' do
      expect {
        post "/admin/weeks/#{week.id}/content_items", params: {
          content_item: {
            title: 'Test',
            kind: 'link',
            url: 'https://example.com'
          }
        }
      }.to change(ContentItem, :count).by(1)
    end
  end

  describe 'PATCH /admin/weeks/:week_id/content_items/:id' do
    let(:content_item) do
      week.content_items.create!(
        title: 'Test',
        kind: 'link',
        url: 'https://example.com'
      )
    end

    it 'should update content item' do
      patch "/admin/weeks/#{week.id}/content_items/#{content_item.id}", params: {
        content_item: { title: 'Updated Title' }
      }
      expect(response).to redirect_to(admin_week_content_item_path(week, content_item))
      expect(content_item.reload.title).to eq('Updated Title')
    end
  end

  describe 'DELETE /admin/weeks/:week_id/content_items/:id' do
    let!(:content_item) do
      week.content_items.create!(
        title: 'Test',
        kind: 'link',
        url: 'https://example.com'
      )
    end

    it 'should delete content item' do
      expect {
        delete "/admin/weeks/#{week.id}/content_items/#{content_item.id}"
      }.to change(ContentItem, :count).by(-1)
    end
  end
end

