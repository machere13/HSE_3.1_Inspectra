require 'rails_helper'

RSpec.describe 'LegacyIframes', type: :request do
  let(:user) { verified_user }
  before { load_all_interactives! }

  def issue_session_for(key, user)
    interactive = Interactive.find_by!(key: key)
    user.interactive_attempts.find_or_create_by!(interactive: interactive).issue_session!
  end

  describe 'GET /legacy/iframes/:seed' do
    it 'renders HTML with HMAC token for valid seed + session' do
      cookies[:token] = encode_test_jwt({ user_id: user.id })
      session = issue_session_for('legacy.ancient_iframe', user)
      get legacy_iframe_path(1, session: session)
      expect(response).to have_http_status(:success)
      interactive = Interactive.find_by!(key: 'legacy.ancient_iframe')
      expected = interactive.issue_token_for(user, variant: interactive.interactive_variants.find_by(seed: 1))
      expect(response.body).to include(expected)
    end

    it 'returns 404 for unknown seed' do
      cookies[:token] = encode_test_jwt({ user_id: user.id })
      issue_session_for('legacy.ancient_iframe', user)
      session = issue_session_for('legacy.ancient_iframe', user)
      get '/legacy/iframes/99', params: { session: session }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 401 when not authenticated' do
      get legacy_iframe_path(1)
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /legacy/archives/:seed' do
    it 'renders HTML with HMAC token for valid seed + session' do
      cookies[:token] = encode_test_jwt({ user_id: user.id })
      session = issue_session_for('legacy.archive_worm', user)
      get legacy_archive_path(1, session: session)
      expect(response).to have_http_status(:success)
      interactive = Interactive.find_by!(key: 'legacy.archive_worm')
      expected = interactive.issue_token_for(user, variant: interactive.interactive_variants.find_by(seed: 1))
      expect(response.body).to include(expected)
    end

    it 'returns 404 for unknown seed' do
      cookies[:token] = encode_test_jwt({ user_id: user.id })
      session = issue_session_for('legacy.archive_worm', user)
      get '/legacy/archives/99', params: { session: session }
      expect(response).to have_http_status(:not_found)
    end
  end
end
