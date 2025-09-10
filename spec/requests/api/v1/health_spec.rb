require 'swagger_helper'

RSpec.describe 'Health Check API', type: :request do
  path '/api/v1/health' do
    get 'Health check endpoint' do
      tags 'Health'
      description 'Returns the health status of the API'
      produces 'application/json'

      response '200', 'API is healthy' do
        schema type: :object,
               properties: {
                 status: { type: :string, example: 'ok' },
                 timestamp: { type: :string, example: '2023-01-01T00:00:00Z' }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('ok')
        end
      end
    end
  end
end
