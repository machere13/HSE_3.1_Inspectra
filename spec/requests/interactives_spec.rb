require 'rails_helper'

RSpec.describe 'Interactives', type: :request do
  let(:user) { verified_user(game_role: nil) }
  before { login_as_web(user) }

  describe 'authentication' do
    it 'redirects unauthenticated user from index' do
      cookies.delete(:token)
      get interactives_path
      expect(response).to redirect_to(auth_path)
    end

    it 'redirects unverified user from show' do
      user.update!(email_verified: false)
      load_all_interactives!
      get interactive_path('dev_diving.secret_message')
      expect(response).to redirect_to(auth_path)
    end
  end

  describe 'GET /interactives (index)' do
    before { load_all_interactives! }

    it 'renders 200 with all categories' do
      get interactives_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Тайное послание')
      expect(response.body).to include('Архивный червь')
      expect(response.body).to include('Фишинговая экспедиция')
    end
  end

  describe 'GET /interactives/:key — smoke test for all 28 interactives' do
    before { load_all_interactives! }

    Interactive::KINDS
    let(:expected_keys) do
      raw = YAML.safe_load_file(
        Rails.root.join('db', 'seeds', 'interactives.yml'),
        permitted_classes: [Date, Symbol], aliases: true
      )
      raw['interactives'].map { |i| i['key'] }
    end

    it 'returns 200 for every key in seeds' do
      expected_keys.each do |key|
        get interactive_path(key)
        expect(response).to have_http_status(:success), "Failed for #{key}: status #{response.status}"
      end
    end

    it 'returns redirect-to-list for unknown key' do
      get '/interactives/this.does.not.exist'
      expect(response).to redirect_to(interactives_path)
    end
  end

  describe 'POST /interactives/:key/submit — happy paths per kind' do
    before { load_all_interactives! }

    def variant_for_user(key, user)
      Interactive.find_by!(key: key).variant_for(user)
    end

    it 'find_text_in_html: correct answer awards XP' do
      v = variant_for_user('dev_diving.secret_message', user)
      expect {
        post submit_interactive_path('dev_diving.secret_message'), params: { answer: v.expected_answer }
      }.to change { user.reload.experience_points }.by_at_least(1)
      expect(response).to redirect_to(interactive_path('dev_diving.secret_message'))
      follow_redirect!
      expect(flash[:notice]).to match(/Получено \d+ XP/)
    end

    it 'find_text_in_html: wrong answer increments attempts, no XP' do
      expect {
        post submit_interactive_path('dev_diving.secret_message'), params: { answer: 'totally-wrong' }
      }.not_to change { user.reload.experience_points }
      attempt = user.interactive_attempts.joins(:interactive).find_by(interactives: { key: 'dev_diving.secret_message' })
      expect(attempt&.count).to eq(1)
    end

    it 'password_crack: MD5 verified password works' do
      v = variant_for_user('it_security.weak_perimeter', user)
      post submit_interactive_path('it_security.weak_perimeter'), params: { answer: v.expected_answer }
      follow_redirect!
      expect(flash[:notice]).to match(/Получено/)
    end

    it 'password_crack: wrong password rejected' do
      post submit_interactive_path('it_security.weak_perimeter'), params: { answer: 'definitely-not-the-password' }
      follow_redirect!
      expect(flash[:alert]).to be_present
    end

    it 'xss_payload: exact payload works' do
      v = variant_for_user('it_security.xss_injection', user)
      post submit_interactive_path('it_security.xss_injection'), params: { answer: v.expected_answer }
      follow_redirect!
      expect(flash[:notice]).to match(/Получено/)
    end

    it 'xss_payload: wrong case rejected' do
      v = variant_for_user('it_security.xss_injection', user)
      post submit_interactive_path('it_security.xss_injection'), params: { answer: v.expected_answer.upcase }
      follow_redirect!
      expect(flash[:alert]).to be_present
    end

    it 'phishing_quiz (email select): correct email_id wins' do
      v = variant_for_user('it_security.phishing_expedition', user)
      post submit_interactive_path('it_security.phishing_expedition'), params: { answer: v.expected_answer }
      follow_redirect!
      expect(flash[:notice]).to match(/Получено/)
    end

    it 'phishing_quiz (markers): set comparison passes regardless of order' do
      v = variant_for_user('it_security.link_swap', user)
      shuffled = v.payload['correct_markers'].shuffle.join(',')
      post submit_interactive_path('it_security.link_swap'), params: { answer: shuffled }
      follow_redirect!
      expect(flash[:notice]).to match(/Получено/)
    end

    it 'phishing_quiz (markers): extra marker fails' do
      v = variant_for_user('it_security.link_swap', user)
      with_extra = (v.payload['correct_markers'] + ['extra']).join(',')
      post submit_interactive_path('it_security.link_swap'), params: { answer: with_extra }
      follow_redirect!
      expect(flash[:alert]).to be_present
    end

    it 'sandbox_code_fix: success token (auto-filled by JS) works' do
      v = variant_for_user('it_errors.recursive_catastrophe', user)
      post submit_interactive_path('it_errors.recursive_catastrophe'), params: { answer: v.expected_answer }
      follow_redirect!
      expect(flash[:notice]).to match(/Получено/)
    end
  end

  describe 'POST /interactives/:key/submit — already-completed' do
    before { load_all_interactives! }

    it 'second submit returns alert, no XP awarded twice' do
      v = Interactive.find_by!(key: 'dev_diving.secret_message').variant_for(user)
      post submit_interactive_path('dev_diving.secret_message'), params: { answer: v.expected_answer }
      xp_after_first = user.reload.experience_points

      post submit_interactive_path('dev_diving.secret_message'), params: { answer: v.expected_answer }
      follow_redirect!
      expect(flash[:alert]).to match(/уже пройден/i)
      expect(user.reload.experience_points).to eq(xp_after_first)
    end
  end

  describe 'POST /interactives/:key/submit — locked after max_attempts' do
    before { load_all_interactives! }

    it 'redirects to /interactives after 5 wrong tries on recursive_catastrophe' do
      key = 'it_errors.recursive_catastrophe'
      5.times do
        post submit_interactive_path(key), params: { answer: 'nope' }
      end
      post submit_interactive_path(key), params: { answer: 'nope' }
      expect(response).to redirect_to(interactives_path)
    end
  end
end
