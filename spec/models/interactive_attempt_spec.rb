require 'rails_helper'

RSpec.describe InteractiveAttempt, type: :model do
  let(:user) { User.create!(email: 'a@x.x', password: 'password123', email_verified: true) }
  let(:interactive) do
    Interactive.create!(
      key: 'attempt.test', kind: 'sandbox_code_fix', category: 'it_errors',
      title: 'T', xp_reward: 50, difficulty: 3
    )
  end

  it 'is unique per (user, interactive)' do
    user.interactive_attempts.create!(interactive: interactive, count: 0)
    duplicate = user.interactive_attempts.build(interactive: interactive, count: 0)
    expect(duplicate).not_to be_valid
  end

  describe '#locked?' do
    let(:attempt) { user.interactive_attempts.create!(interactive: interactive, count: 0) }

    it 'is false when locked_until is nil' do
      expect(attempt.locked?).to be false
    end

    it 'is false when locked_until in the past' do
      attempt.update!(locked_until: 1.minute.ago)
      expect(attempt.locked?).to be false
    end

    it 'is true when locked_until in the future' do
      attempt.update!(locked_until: 1.hour.from_now)
      expect(attempt.locked?).to be true
    end
  end

  describe '#attempts_left' do
    let(:attempt) { user.interactive_attempts.create!(interactive: interactive, count: 2) }

    it 'returns nil when max_attempts is nil' do
      expect(attempt.attempts_left(nil)).to be_nil
    end

    it 'returns positive remaining' do
      expect(attempt.attempts_left(5)).to eq(3)
    end

    it 'caps at zero' do
      attempt.update!(count: 10)
      expect(attempt.attempts_left(5)).to eq(0)
    end
  end

  describe '#register_fail!' do
    let(:attempt) { user.interactive_attempts.create!(interactive: interactive, count: 0) }

    it 'increments count' do
      expect { attempt.register_fail! }.to change { attempt.reload.count }.from(0).to(1)
    end

    it 'sets last_attempt_at' do
      attempt.register_fail!
      expect(attempt.reload.last_attempt_at).to be_within(2.seconds).of(Time.current)
    end

    it 'does not set locked_until without max_attempts' do
      3.times { attempt.register_fail! }
      expect(attempt.reload.locked_until).to be_nil
    end

    it 'does not lock if count < max_attempts' do
      attempt.register_fail!(max_attempts: 5)
      attempt.register_fail!(max_attempts: 5)
      expect(attempt.reload.locked_until).to be_nil
    end

    it 'locks when count reaches max_attempts' do
      5.times { attempt.register_fail!(max_attempts: 5, lock_minutes: 30) }
      attempt.reload
      expect(attempt.locked_until).to be_present
      expect(attempt.locked_until).to be_within(2.seconds).of(30.minutes.from_now)
    end
  end
end
