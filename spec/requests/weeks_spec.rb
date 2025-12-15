require 'rails_helper'

RSpec.describe 'Weeks', type: :request do
  describe 'GET /weeks/:id' do
    let!(:visible_week) do
      Week.create!(
        number: 1,
        title: 'Visible Week',
        published_at: 1.day.ago,
        expires_at: 1.day.from_now
      )
    end

    it 'should get show for visible week' do
      get week_path(visible_week)
      expect(response).to have_http_status(:success)
    end

    it 'should return 404 for expired week' do
      expired_week = Week.create!(
        number: 2,
        title: 'Expired Week',
        published_at: 1.day.ago,
        expires_at: 1.day.from_now
      )
      expired_week.update_columns(published_at: 2.days.ago, expires_at: 1.day.ago)
      get week_path(expired_week.reload)
      expect(response).to have_http_status(:not_found)
    end

    it 'should return 404 for non-existent week' do
      get '/weeks/999'
      expect(response).to have_http_status(:not_found)
    end

    it 'should show content items' do
      content_item = visible_week.content_items.create!(
        title: 'Test',
        kind: 'link',
        url: 'https://example.com'
      )
      get week_path(visible_week)
      expect(response).to have_http_status(:success)
    end
  end
end

