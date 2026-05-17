require 'rails_helper'

RSpec.describe InteractiveSession, type: :service do
  let(:user) { User.create!(email: 's@x.x', password: 'password123', email_verified: true) }

  let(:interactive) do
    Interactive.create!(
      key: 'session.test', kind: 'find_text_in_html', category: 'dev_diving',
      title: 'T', xp_reward: 50, difficulty: 1
    )
  end
  let!(:variant) do
    interactive.interactive_variants.create!(
      seed: 1, payload: { 'expected_answer' => 'kraken', 'hidden_text' => 'kraken' }
    )
  end

  subject(:session) { described_class.new(user: user, interactive: interactive) }

  describe '#variant' do
    it 'returns the assigned variant' do
      expect(session.variant).to eq(variant)
    end

    it 'returns nil when interactive has no variants' do
      empty = Interactive.create!(
        key: 'session.empty', kind: 'find_text_in_html', category: 'dev_diving',
        title: 'T', xp_reward: 50, difficulty: 1
      )
      expect(described_class.new(user: user, interactive: empty).variant).to be_nil
    end

    it 'returns same variant on multiple calls' do
      v1 = session.variant
      v2 = session.variant
      expect(v1).to eq(v2)
    end

    it 'persists variant via completion' do
      session.submit('kraken')
      new_session = described_class.new(user: user, interactive: interactive)
      expect(new_session.variant).to eq(variant)
    end
  end

  describe '#submit (success)' do
    it 'creates an InteractiveCompletion' do
      expect { session.submit('kraken') }.to change(InteractiveCompletion, :count).by(1)
    end

    it 'returns success: true' do
      result = session.submit('kraken')
      expect(result.success?).to be true
      expect(result.error_message).to be_nil
    end

    it 'awards XP to user' do
      expect { session.submit('kraken') }.to change { user.reload.experience_points }.by(50)
    end
  end

  describe '#submit (wrong answer)' do
    it 'does not create completion' do
      expect { session.submit('wrong') }.not_to change(InteractiveCompletion, :count)
    end

    it 'returns success: false' do
      result = session.submit('wrong')
      expect(result.success?).to be false
      expect(result.error_message).to be_present
    end

    it 'increments attempts counter' do
      session.submit('wrong')
      session.submit('wrong')
      attempt = user.interactive_attempts.find_by(interactive: interactive)
      expect(attempt.count).to eq(2)
    end
  end

  describe '#submit when already completed' do
    before { session.submit('kraken') }

    it 'returns success: false with already-completed message' do
      new_session = described_class.new(user: user, interactive: interactive)
      result = new_session.submit('kraken')
      expect(result.success?).to be false
      expect(result.error_message).to match(/уже пройден/i)
    end

    it 'does not double-award XP' do
      new_session = described_class.new(user: user, interactive: interactive)
      expect { new_session.submit('kraken') }.not_to change { user.reload.experience_points }
    end
  end

  describe '#submit with max_attempts (locking)' do
    let(:interactive) do
      Interactive.create!(
        key: 'session.attempts', kind: 'sandbox_code_fix', category: 'it_errors',
        title: 'T', xp_reward: 100, difficulty: 5
      )
    end
    let!(:variant) do
      interactive.interactive_variants.create!(
        seed: 1, payload: { 'expected_answer' => 'right', 'max_attempts' => 3 }
      )
    end

    it 'locks after max_attempts wrong submissions' do
      3.times { session.submit('wrong') }
      attempt = user.interactive_attempts.find_by(interactive: interactive)
      expect(attempt.locked?).to be true
    end

    it 'next submit returns locked: true' do
      3.times { session.submit('wrong') }
      new_session = described_class.new(user: user, interactive: interactive)
      result = new_session.submit('right')
      expect(result.success?).to be false
      expect(result.locked).to be true
    end

    it 'allows submit until limit reached' do
      r1 = session.submit('wrong')
      r2 = session.submit('wrong')
      expect(r1.locked).to be_falsey
      expect(r2.locked).to be_falsey
    end
  end

  describe '#submit with warrior role for it_errors' do
    let(:interactive) do
      Interactive.create!(
        key: 'session.warrior', kind: 'sandbox_code_fix', category: 'it_errors',
        title: 'T', xp_reward: 100, difficulty: 5
      )
    end
    let!(:variant) do
      interactive.interactive_variants.create!(
        seed: 1, payload: { 'expected_answer' => 'r', 'max_attempts' => 3 }
      )
    end

    it 'gives +1 attempt to warrior' do
      user.update!(game_role: 'warrior')
      expect(session.max_attempts).to eq(4)
    end

    it 'does NOT give bonus to non-warrior' do
      user.update!(game_role: 'mage')
      expect(session.max_attempts).to eq(3)
    end

    it 'does NOT give warrior bonus on non-it_errors category' do
      interactive.update!(category: 'dev_diving')
      user.update!(game_role: 'warrior')
      expect(session.max_attempts).to eq(3)
    end

    it 'warrior in it_errors gets 4 attempts before lock' do
      user.update!(game_role: 'warrior')
      4.times { session.submit('wrong') }
      attempt = user.interactive_attempts.find_by(interactive: interactive)
      expect(attempt.locked?).to be true
    end
  end
end
