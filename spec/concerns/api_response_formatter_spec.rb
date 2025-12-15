require 'rails_helper'

RSpec.describe ApiResponseFormatter, type: :controller do
  controller(Api::V1::HealthController) do
    include ApiResponseFormatter

    def test_success
      render_success(data: { test: 'data' }, message: 'Success')
    end

    def test_error
      render_error(code: 'TEST_ERROR', message: 'Test error')
    end

    def test_validation_error
      render_validation_error(message: 'Validation failed')
    end

    def test_not_found
      render_not_found(message: 'Not found')
    end

    def test_unauthorized
      render_unauthorized(message: 'Unauthorized')
    end
  end

  before do
    routes.draw do
      get 'test_success' => 'api/v1/health#test_success'
      get 'test_error' => 'api/v1/health#test_error'
      get 'test_validation_error' => 'api/v1/health#test_validation_error'
      get 'test_not_found' => 'api/v1/health#test_not_found'
      get 'test_unauthorized' => 'api/v1/health#test_unauthorized'
    end
  end

  describe '#render_success' do
    it 'should render success response' do
      get :test_success
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['data']['test']).to eq('data')
      expect(json_response['message']).to eq('Success')
    end
  end

  describe '#render_error' do
    it 'should render error response' do
      get :test_error
      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be false
      expect(json_response['error']['code']).to eq('TEST_ERROR')
    end
  end

  describe '#render_validation_error' do
    it 'should render validation error' do
      get :test_validation_error
      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body)
      expect(json_response['error']['code']).to eq(ApiResponseFormatter::ERROR_CODES[:validation_error])
    end
  end

  describe '#render_not_found' do
    it 'should render not found' do
      get :test_not_found
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']['code']).to eq(ApiResponseFormatter::ERROR_CODES[:not_found])
    end
  end

  describe '#render_unauthorized' do
    it 'should render unauthorized' do
      get :test_unauthorized
      expect(response).to have_http_status(:unauthorized)
      json_response = JSON.parse(response.body)
      expect(json_response['error']['code']).to eq(ApiResponseFormatter::ERROR_CODES[:unauthorized])
    end
  end
end

