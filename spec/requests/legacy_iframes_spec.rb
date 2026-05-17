require 'rails_helper'

RSpec.describe 'LegacyIframes', type: :request do
  before { load_all_interactives! }

  describe 'GET /legacy/iframes/:seed' do
    it 'renders raw HTML page with answer for valid seed' do
      get legacy_iframe_path(1)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('text/html')
      variant = Interactive.find_by!(key: 'legacy.ancient_iframe').interactive_variants.find_by(seed: 1)
      expect(response.body).to include(variant.expected_answer)
    end

    it 'returns 404 for unknown seed' do
      get '/legacy/iframes/99'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /legacy/archives/:seed' do
    it 'renders raw HTML page with answer' do
      get legacy_archive_path(1)
      expect(response).to have_http_status(:success)
      variant = Interactive.find_by!(key: 'legacy.archive_worm').interactive_variants.find_by(seed: 1)
      expect(response.body).to include(variant.expected_answer)
    end

    it 'returns 404 for unknown seed' do
      get '/legacy/archives/99'
      expect(response).to have_http_status(:not_found)
    end
  end
end
