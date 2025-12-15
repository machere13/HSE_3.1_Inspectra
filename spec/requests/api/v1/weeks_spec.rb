require 'rails_helper'

RSpec.describe 'API::V1::Weeks', type: :request do
  describe 'GET /api/v1/weeks' do
    let!(:visible_week) do
      Week.create!(
        number: 1,
        title: 'Visible Week',
        published_at: 1.day.ago,
        expires_at: 1.day.from_now
      )
    end
    let!(:expired_week) do
      week = Week.create!(
        number: 2,
        title: 'Expired Week',
        published_at: 1.day.ago,
        expires_at: 1.day.from_now
      )
      week.update_columns(published_at: 2.days.ago, expires_at: 1.day.ago)
      week.reload
    end

    it 'should return only visible weeks' do
      get '/api/v1/weeks'
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      week_numbers = json_response['data'].map { |w| w['number'] }
      expect(week_numbers).to include(visible_week.number)
      expect(week_numbers).not_to include(expired_week.number)
    end

    it 'should include articles and content_items' do
      article = visible_week.articles.create!(title: 'Test', body: 'Body')
      get '/api/v1/weeks'
      json_response = JSON.parse(response.body)
      week_data = json_response['data'].find { |w| w['number'] == visible_week.number }
      expect(week_data['articles']).to be_an(Array)
    end
  end

  describe 'GET /api/v1/weeks/:id' do
    let!(:week) do
      Week.create!(
        number: 1,
        title: 'Test Week',
        published_at: 1.day.ago,
        expires_at: 1.day.from_now
      )
    end

    it 'should return week by number' do
      get "/api/v1/weeks/#{week.number}"
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['number']).to eq(week.number)
    end

    it 'should return week by id' do
      get "/api/v1/weeks/#{week.id}"
      expect(response).to have_http_status(:success)
    end

    it 'should return 404 for non-existent week' do
      get '/api/v1/weeks/999'
      expect(response).to have_http_status(:not_found)
    end

    it 'should return 404 for expired week' do
      expired = Week.create!(
        number: 99,
        title: 'Expired',
        published_at: 2.days.ago,
        expires_at: 1.day.ago
      )
      get "/api/v1/weeks/#{expired.number}"
      expect(response).to have_http_status(:not_found)
    end
  end
end

