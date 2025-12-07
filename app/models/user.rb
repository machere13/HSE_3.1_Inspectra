class User < ApplicationRecord
  has_secure_password
  
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements
  
  has_many :user_titles, dependent: :destroy
  has_many :titles, through: :user_titles
  belongs_to :current_title, class_name: 'Title', optional: true
  
  has_one_attached :avatar
  
  enum :role, {
    user: 0,
    moderator: 1,
    admin: 2,
    super_admin: 3
  }
  
  CODE_METAPHOR_PREFIXES = [
    'Code', 'Bug', 'Syntax', 'Debug', 'Byte', 'Bit', 'Stack', 'Heap', 'Queue', 'Tree',
    'Node', 'Array', 'Hash', 'List', 'Set', 'Map', 'Graph', 'Loop', 'Recursion', 'Lambda',
    'Function', 'Class', 'Object', 'Method', 'Variable', 'Constant', 'String', 'Integer',
    'Float', 'Boolean', 'Null', 'Void', 'Return', 'Break', 'Continue', 'Async', 'Promise',
    'Callback', 'Event', 'Stream', 'Buffer', 'Cache', 'Cookie', 'Session', 'Token', 'Key',
    'Value', 'Index', 'Pointer', 'Reference', 'Instance', 'Static', 'Public', 'Private',
    'Protected', 'Abstract', 'Interface', 'Trait', 'Module', 'Package', 'Import', 'Export',
    'Require', 'Include', 'Extend', 'Inherit', 'Override', 'Polymorph', 'Encapsulate',
    'Abstraction', 'Inheritance', 'Composition', 'Aggregation', 'Dependency', 'Association'
  ].freeze

  CODE_METAPHOR_SUFFIXES = [
    'Ninja', 'Master', 'Wizard', 'Hunter', 'Warrior', 'Knight', 'Guardian', 'Defender',
    'Builder', 'Creator', 'Maker', 'Designer', 'Architect', 'Engineer', 'Developer',
    'Coder', 'Programmer', 'Hacker', 'Guru', 'Expert', 'Pro', 'Elite', 'Legend',
    'Hero', 'Champion', 'Ace', 'Star', 'Genius', 'Savant', 'Virtuoso', 'Maestro',
    'Pioneer', 'Trailblazer', 'Innovator', 'Visionary', 'Strategist', 'Tactician',
    'Solver', 'Fixer', 'Optimizer', 'Refactorer', 'Debugger', 'Tester', 'Validator',
    'Executor', 'Runner', 'Processor', 'Handler', 'Manager', 'Controller', 'Router',
    'Service', 'Repository', 'Factory', 'Builder', 'Singleton', 'Observer', 'Mediator'
  ].freeze

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: AppConfig::Auth.password_min_length, maximum: AppConfig::Auth.password_max_length }, if: -> { new_record? || !password.nil? }
  
  before_validation :generate_name_if_blank, on: :create
  after_create :check_registration_achievements
  
  def generate_verification_code!
    self.verification_code = SecureRandom.random_number(1000000).to_s.rjust(6, '0')
    self.verification_code_expires_at = AppConfig::Auth.verification_code_ttl_minutes.from_now
    save!
  end
  
  def verification_code_valid?(code)
    verification_code == code && 
    verification_code_expires_at.present? && 
    verification_code_expires_at > Time.current
  end
  
  def verify_email!
    update!(email_verified: true, verification_code: nil, verification_code_expires_at: nil)
  end
  
  def email_verification_required?
    !email_verified?
  end
  
  def completed_achievements
    user_achievements.completed.includes(:achievement)
  end
  
  def in_progress_achievements
    user_achievements.in_progress.includes(:achievement)
  end
  
  def achievement_progress(achievement)
    user_achievements.find_by(achievement: achievement)&.progress || 0
  end
  
  def has_achievement?(achievement)
    user_achievements.exists?(achievement: achievement, completed_at: ..Time.current)
  end
  
  def has_title?(title)
    user_titles.exists?(title: title)
  end
  
  def available_titles
    Title.joins(:user_titles).where(user_titles: { user_id: id }).order('user_titles.earned_at DESC')
  end
  
  def select_title!(title)
    raise ArgumentError unless has_title?(title)
    update!(current_title: title)
  end
  
  def current_title_name
    current_title&.name
  end
  
  private
  
  def check_registration_achievements
    AchievementService.new(self).check_achievements_for_registration_order
  end

  public

  def generate_reset_password_token!
    update!(
      reset_password_token: SecureRandom.urlsafe_base64(32),
      reset_password_sent_at: Time.current,
      reset_password_requested_at: Time.current
    )
  end

  def clear_reset_password_token!
    update!(reset_password_token: nil, reset_password_sent_at: nil)
  end

  def reset_token_valid?(ttl_minutes: nil)
    ttl = ttl_minutes || AppConfig::Auth.reset_password_token_ttl_minutes.to_i / 60
    reset_password_token.present? && reset_password_sent_at.present? && reset_password_sent_at > ttl.minutes.ago
  end

  def generate_code_metaphor_name!
    loop do
      generated_name = generate_code_metaphor_name
      unless User.exists?(name: generated_name)
        self.name = generated_name
        break
      end
    end
  end

  private

  def generate_name_if_blank
    return if name.present?
    generate_code_metaphor_name!
  end

  def generate_code_metaphor_name
    prefix = CODE_METAPHOR_PREFIXES.sample
    suffix = CODE_METAPHOR_SUFFIXES.sample
    number = rand(100..9999)
    
    "#{prefix}#{suffix}#{number}"
  end
end
