require 'rails_helper'

RSpec.describe 'Days', type: :request do
  describe 'GET /days/:id' do
    it 'should get show' do
      day = Day.create!(number: 1, title: 'Test Day', description: 'Test')
      
      get day_path(day)
      expect(response).to have_http_status(:success)
    end
  end
end

