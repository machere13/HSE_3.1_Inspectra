module InteractiveSpecHelper
  def login_as_web(user)
    cookies[:token] = encode_test_jwt({ user_id: user.id })
  end

  def auth_headers_for(user)
    { 'Authorization' => "Bearer #{encode_test_jwt({ user_id: user.id })}" }
  end

  def verified_user(attrs = {})
    defaults = {
      email: "user#{SecureRandom.hex(4)}@example.com",
      password: 'password123',
      email_verified: true
    }
    User.create!(defaults.merge(attrs))
  end

  def load_all_interactives!
    raw = YAML.safe_load_file(
      Rails.root.join('db', 'seeds', 'interactives.yml'),
      permitted_classes: [Date, Symbol],
      aliases: true
    )
    raw['interactives'].each do |row|
      variants = row['variants'] || []
      interactive_attrs = row.except('variants')
      interactive = Interactive.find_or_initialize_by(key: interactive_attrs['key'])
      interactive.assign_attributes(interactive_attrs)
      interactive.save!

      variants.each do |v|
        seed_num = v['seed']
        payload = v.reject { |k, _| k == 'seed' }
        variant = interactive.interactive_variants.find_or_initialize_by(seed: seed_num)
        variant.payload = payload
        variant.save!
      end
    end
  end

  def build_interactive(key:, kind: 'find_text_in_html', category: 'dev_diving', xp_reward: 50, difficulty: 1, payload: {}, expected_answer: 'answer')
    interactive = Interactive.create!(
      key: key, kind: kind, category: category, title: key, description: "spec",
      xp_reward: xp_reward, difficulty: difficulty
    )
    interactive.interactive_variants.create!(
      seed: 1, payload: payload.merge('expected_answer' => expected_answer)
    )
    interactive
  end
end

RSpec.configure do |config|
  config.include InteractiveSpecHelper
end
