require 'rails_helper'

RSpec.describe 'Weeks', type: :request do
  describe 'GET /weeks/:id' do
    it 'should get show' do
      week = Week.create!(number: 1, title: 'Test Week', description: 'Test')
      
      get week_path(week)
      expect(response).to have_http_status(:success)
    end
  end
end

