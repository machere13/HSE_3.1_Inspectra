require 'rails_helper'

RSpec.describe 'Errors', type: :request do
  describe 'GET /422' do
    it 'renders 422 page' do
      get '/422'

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to include('text/html')
    end
  end

  describe 'GET /429' do
    it 'renders 429 page' do
      get '/429'

      expect(response).to have_http_status(:too_many_requests)
      expect(response.content_type).to include('text/html')
    end
  end

  describe 'POST /report_problem' do
    it 'creates an error report' do
      expect do
        post report_problem_path, params: {
          page_url: 'http://example.com/500',
          status_code: '500',
          message: 'Что-то сломалось на странице'
        }
      end.to change(ErrorReport, :count).by(1)

      expect(response).to redirect_to(root_path)
      report = ErrorReport.last
      expect(report.page_url).to eq('http://example.com/500')
      expect(report.status_code).to eq('500')
      expect(report.message).to eq('Что-то сломалось на странице')
    end

    it 'does not create an invalid error report' do
      expect do
        post report_problem_path, params: { message: '' }
      end.not_to change(ErrorReport, :count)

      expect(response).to redirect_to(root_path)
    end
  end
end
require 'rails_helper'

RSpec.describe 'Errors', type: :request do
  describe 'GET /*unmatched' do
    it 'should return 404 for non-existent route' do
      get '/non-existent-route'
      expect(response).to have_http_status(:not_found)
    end

    it 'should render HTML for HTML request' do
      get '/non-existent-route', headers: { 'Accept' => 'text/html' }
      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to include('text/html')
    end

    it 'should render JSON for JSON request' do
      get '/non-existent-route', headers: { 'Accept' => 'application/json' }
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Not Found')
    end
  end
end

