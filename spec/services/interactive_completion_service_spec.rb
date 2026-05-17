require 'rails_helper'

RSpec.describe InteractiveCompletionService, type: :service do
  before do
    UserTitle.delete_all
    UserAchievement.delete_all
    User.update_all(current_title_id: nil)
    Achievement.delete_all
    Title.where.not(id: nil).delete_all
  end

  let(:user) { User.create!(email: 'c@x.x', password: 'password123', email_verified: true) }
  let(:interactive) do
    Interactive.create!(
      key: 'completion.test', kind: 'find_text_in_html', category: 'it_security',
      title: 'T', xp_reward: 100, difficulty: 2
    )
  end
  let(:variant) do
    interactive.interactive_variants.create!(
      seed: 1, payload: { 'expected_answer' => 'foo' }
    )
  end

  subject(:service) { described_class.new(user: user, interactive: interactive, variant: variant) }

  describe '#complete!' do
    it 'creates a completion with metadata' do
      completion = service.complete!
      expect(completion).to be_persisted
      expect(completion.metadata['variant_seed']).to eq(1)
      expect(completion.metadata['xp_awarded']).to eq(100)
    end

    it 'awards base XP for unmatched class' do
      user.update!(game_role: nil)
      expect { service.complete! }.to change { user.reload.experience_points }.by(100)
    end

    it 'awards +15% XP for matching specialty (mage / it_security)' do
      user.update!(game_role: 'mage')
      expect { service.complete! }.to change { user.reload.experience_points }.by(115)
    end

    it 'does not award bonus for non-matching class' do
      user.update!(game_role: 'priest')
      expect { service.complete! }.to change { user.reload.experience_points }.by(100)
    end

    it 'rounds XP bonus correctly' do
      interactive.update!(xp_reward: 70)
      user.update!(game_role: 'mage')
      expect { service.complete! }.to change { user.reload.experience_points }.by(81)
    end

    it 'returns new_titles array (empty if no achievements)' do
      service.complete!
      expect(service.new_titles).to be_empty
    end
  end

  describe '#complete! triggers achievement service' do
    let!(:achievement) do
      Achievement.create!(
        name: 'First step', category: 'it_security', progress_type: 'total_interactives',
        progress_target: 1
      )
    end
    let!(:title) do
      Title.create!(name: 'Newbie title', description: 'first')
    end

    before { achievement.update!(title: title) }

    it 'creates user_achievement progressed by 1' do
      service.complete!
      ua = user.user_achievements.find_by(achievement: achievement)
      expect(ua.progress).to eq(1)
      expect(ua.completed?).to be true
    end

    it 'awards the linked title' do
      service.complete!
      expect(user.titles.reload).to include(title)
    end

    it 'sets current_title if blank' do
      service.complete!
      expect(user.reload.current_title).to eq(title)
    end

    it 'returns new_titles' do
      service.complete!
      expect(service.new_titles).to include(title)
    end

    it 'does NOT double-award title on repeated completion of different interactive' do
      service.complete!
      first_count = user.user_titles.count

      other = Interactive.create!(
        key: 'other', kind: 'find_text_in_html', category: 'it_security',
        title: 'O', xp_reward: 50, difficulty: 1
      )
      v = other.interactive_variants.create!(seed: 1, payload: { 'expected_answer' => 'bar' })
      described_class.new(user: user, interactive: other, variant: v).complete!

      expect(user.reload.user_titles.count).to eq(first_count)
    end
  end
end
