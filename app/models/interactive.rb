class Interactive < ApplicationRecord
  has_many :interactive_variants, dependent: :destroy
  has_many :completions, class_name: 'InteractiveCompletion', dependent: :destroy
  belongs_to :article, optional: true

  KINDS = %w[
    find_text_in_html
    inspect_devtools
    console_input
    user_agent_swap
    iframe_hunt
    sandbox_code_fix
    phishing_quiz
    password_crack
    xss_payload
  ].freeze

  RANDOMIZABLE_KINDS = %w[
    find_text_in_html
    inspect_devtools
    console_input
    user_agent_swap
    iframe_hunt
    sandbox_code_fix
  ].freeze

  STATIC_ANSWER_KINDS = %w[password_crack xss_payload phishing_quiz].freeze

  SEMANTIC_ANSWER_KEYS = %w[
    legacy.deprecation_encyclopedia
    legacy.relic_layout
    legacy.ghost_format
    it_security.deprecated_dangerous
    dev_diving.missing_cookie
    it_errors.silent_failure
    it_errors.memory_leak
  ].freeze

  TOKEN_PREFIXES = {
    'dev_diving.network_spy'         => 'NET',
    'dev_diving.event_listener'      => 'EV',
    'dev_diving.missing_cookie'      => 'COOKIE',
    'dev_diving.blind_in_dom'        => 'BLIND',
    'dev_diving.css_labyrinth'       => 'CSS',
    'dev_diving.secret_message'      => 'MSG',
    'dev_diving.hidden_js_script'    => 'JS',
    'legacy.echo_of_past'            => 'ECHO',
    'legacy.ie6_hack'                => 'IE6',
    'legacy.ancient_iframe'          => 'IF',
    'legacy.archive_worm'            => 'ARCHIVE',
    'legacy.deprecation_encyclopedia'=> 'DEPR',
    'legacy.relic_layout'            => 'RELIC',
    'legacy.ghost_format'            => 'FMT',
    'it_errors.silent_failure'       => 'IMG',
    'it_errors.blind_check'          => 'PWD',
    'it_errors.data_race'            => 'RACE',
    'it_errors.memory_leak'          => 'LEAK',
    'it_errors.groundhog_day'        => 'LOOP',
    'it_errors.error_chain'          => 'CHAIN',
    'it_errors.recursive_catastrophe'=> 'REC',
    'it_security.unsecured_keys'     => 'ADMIN',
    'it_security.deprecated_dangerous'=> 'LIBVER',
    'it_security.broken_perms'       => 'APIKEY'
  }.freeze

  validates :key, presence: true, uniqueness: true
  validates :title, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES = %w[dev_diving legacy it_errors it_security] }
  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :xp_reward, numericality: { greater_than_or_equal_to: 0 }

  scope :by_category, ->(c) { where(category: c) }

  def variant_for(user)
    list = interactive_variants.order(:seed).to_a
    return nil if list.empty?
    idx = user.id.to_i % list.size
    list[idx]
  end

  def randomizable?
    RANDOMIZABLE_KINDS.include?(kind) && !SEMANTIC_ANSWER_KEYS.include?(key)
  end

  def issue_token_for(user, variant: nil)
    seed = variant&.seed || variant_for(user)&.seed || 1
    raw = "#{user.id}|#{key}|seed=#{seed}"
    digest = OpenSSL::HMAC.hexdigest('SHA256', token_secret, raw)[0, 10].upcase
    prefix = TOKEN_PREFIXES[key]
    prefix ? "#{prefix}-#{digest}" : digest
  end

  private

  def token_secret
    Rails.application.secret_key_base.to_s
  end
end
