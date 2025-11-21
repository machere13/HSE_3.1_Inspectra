require 'rails_helper'

RSpec.describe UserAchievement, type: :model do
  let(:user) { User.create!(email: "test@example.com", password: "password123") }
  let(:achievement) do
    Achievement.create!(
      name: "Тестовое достижение",
      description: "Описание тестового достижения",
      category: "general",
      progress_type: "total_interactives",
      progress_target: 10
    )
  end
  let!(:user_achievement) do
    UserAchievement.create!(
      user: user,
      achievement: achievement,
      progress: 5
    )
  end

  describe 'validations' do
    it 'should be valid with valid attributes' do
      expect(user_achievement).to be_valid
    end

    context 'progress' do
      it 'should require progress' do
        user_achievement.progress = nil
        expect(user_achievement).not_to be_valid
      end

      it 'should not allow negative progress' do
        user_achievement.progress = -1
        expect(user_achievement).not_to be_valid
      end
    end

    it 'should be unique per user and achievement' do
      duplicate = UserAchievement.new(user: user, achievement: achievement, progress: 3)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end
  end

  describe 'associations' do
    it 'should belong to user' do
      expect(user_achievement.user).to eq(user)
    end

    it 'should belong to achievement' do
      expect(user_achievement.achievement).to eq(achievement)
    end
  end

  describe '#completed?' do
    it 'should return true when completed_at is present' do
      user_achievement.update!(completed_at: Time.current)
      expect(user_achievement.completed?).to be true
    end

    it 'should return false when completed_at is nil' do
      expect(user_achievement.completed?).to be false
    end
  end

  describe '#progress_percentage' do
    it 'should calculate correctly' do
      expect(user_achievement.progress_percentage).to eq(50)
    end

    it 'should not exceed 100' do
      user_achievement.update!(progress: 15)
      expect(user_achievement.progress_percentage).to eq(100)
    end

    it 'should return 0 when progress_target is zero' do
      achievement.update_columns(progress_target: 0)
      expect(user_achievement.progress_percentage).to eq(0)
    end
  end
end

