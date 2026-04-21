require 'rails_helper'

RSpec.describe 'Admin::ErrorReports', type: :request do
  let(:admin_user) { User.create!(email: 'admin@example.com', password: 'password123', email_verified: true, role: :admin) }
  let(:token) { encode_test_jwt({ user_id: admin_user.id }) }

  before do
    cookies[:token] = token
  end

  describe 'GET /admin/error_reports' do
    it 'requires admin access' do
      regular_user = User.create!(email: 'user@example.com', password: 'password123', email_verified: true)
      cookies[:token] = encode_test_jwt({ user_id: regular_user.id })

      get '/admin/error_reports'

      expect(response).to redirect_to(auth_path)
    end

    it 'shows error reports for admin' do
      ErrorReport.create!(status_code: '500', page_url: 'http://example.com/500', message: 'Ошибка в приложении')

      get '/admin/error_reports'

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Ошибка в приложении')
    end
  end
end
