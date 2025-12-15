require 'rails_helper'

RSpec.describe JwtHelper, type: :controller do
  controller(Api::V1::HealthController) do
    include JwtHelper

    def test_encode
      render json: { token: encode_token({ user_id: 1 }) }
    end

    def test_decode
      token = params[:token]
      decoded = decode_token(token)
      render json: { decoded: decoded }
    end

    def test_current_user
      render json: { user_id: current_user&.id }
    end
  end

  before do
    routes.draw do
      get 'test_encode' => 'api/v1/health#test_encode'
      get 'test_decode' => 'api/v1/health#test_decode'
      get 'test_current_user' => 'api/v1/health#test_current_user'
    end
  end

  describe '#encode_token' do
    it 'should encode token with payload' do
      get :test_encode
      json_response = JSON.parse(response.body)
      expect(json_response['token']).to be_present
    end
  end

  describe '#decode_token' do
    it 'should decode valid token' do
      token = encode_test_jwt({ user_id: 1 })
      get :test_decode, params: { token: token }
      json_response = JSON.parse(response.body)
      expect(json_response['decoded']['user_id']).to eq(1)
    end

    it 'should return nil for invalid token' do
      get :test_decode, params: { token: 'invalid' }
      json_response = JSON.parse(response.body)
      expect(json_response['decoded']).to be_nil
    end
  end

  describe '#current_user' do
    let(:user) { User.create!(email: 'test@example.com', password: 'password123', email_verified: true) }

    it 'should return user from token' do
      token = encode_test_jwt({ user_id: user.id })
      request.headers['Authorization'] = "Bearer #{token}"
      get :test_current_user
      json_response = JSON.parse(response.body)
      expect(json_response['user_id']).to eq(user.id)
    end

    it 'should return nil without token' do
      get :test_current_user
      json_response = JSON.parse(response.body)
      expect(json_response['user_id']).to be_nil
    end
  end
end

