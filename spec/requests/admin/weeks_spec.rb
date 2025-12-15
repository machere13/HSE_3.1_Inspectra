require 'rails_helper'

RSpec.describe 'Admin::Weeks', type: :request do
  let(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', email_verified: true, role: :admin) }
  let(:token) { encode_test_jwt({ user_id: admin_user.id }) }

  before do
    cookies[:token] = token
  end

  describe 'GET /admin/weeks' do
    it 'should list weeks' do
      Week.create!(number: 1, title: 'Test Week')
      get '/admin/weeks'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /admin/weeks/:id' do
    let(:week) { Week.create!(number: 1, title: 'Test Week') }

    it 'should show week' do
      get "/admin/weeks/#{week.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /admin/weeks' do
    it 'should create week' do
      initial_count = Week.count
      post '/admin/weeks', params: {
        week: {
          number: 1,
          title: 'New Week',
          description: 'Description'
        }
      }
      expect(Week.count).to be > initial_count
    end
  end

  describe 'PATCH /admin/weeks/:id' do
    let(:week) { Week.create!(number: 1, title: 'Test Week') }

    it 'should update week' do
      patch "/admin/weeks/#{week.id}", params: {
        week: { title: 'Updated Title' }
      }
      expect(response).to redirect_to(admin_week_path(week))
      expect(week.reload.title).to eq('Updated Title')
    end
  end

  describe 'DELETE /admin/weeks/:id' do
    let!(:week) { Week.create!(number: 1, title: 'Test Week') }

    it 'should delete week' do
      expect {
        delete "/admin/weeks/#{week.id}"
      }.to change(Week, :count).by(-1)
    end
  end
end

