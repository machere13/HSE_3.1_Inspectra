require 'rails_helper'

RSpec.describe Achievement, type: :model do
  let(:achievement) do
    Achievement.new(
      name: "Тестовое достижение",
      description: "Описание тестового достижения",
      category: "general",
      progress_type: "total_interactives",
      progress_target: 10
    )
  end

  describe 'validations' do
    it 'should be valid with valid attributes' do
      expect(achievement).to be_valid
    end

    it 'should require name' do
      achievement.name = nil
      expect(achievement).not_to be_valid
    end

    it 'should require unique name' do
      achievement.save!
      duplicate_achievement = achievement.dup
      expect(duplicate_achievement).not_to be_valid
    end

    it 'should require category' do
      achievement.category = nil
      expect(achievement).not_to be_valid
    end

    it 'should require progress_type' do
      achievement.progress_type = nil
      expect(achievement).not_to be_valid
    end

    context 'progress_target' do
      it 'should require progress_target' do
        achievement.progress_target = nil
        expect(achievement).not_to be_valid
      end

      it 'should not allow zero progress_target' do
        achievement.progress_target = 0
        expect(achievement).not_to be_valid
      end

      it 'should not allow negative progress_target' do
        achievement.progress_target = -1
        expect(achievement).not_to be_valid
      end
    end
  end

  describe 'associations' do
    it 'should have many user_achievements' do
      achievement.save!
      user = User.create!(email: "test@example.com", password: "password123")
      user_achievement = achievement.user_achievements.create!(user: user, progress: 5)

      expect(achievement.user_achievements).to include(user_achievement)
    end

    it 'should have many users through user_achievements' do
      achievement.save!
      user = User.create!(email: "test@example.com", password: "password123")
      achievement.user_achievements.create!(user: user, progress: 5)

      expect(achievement.users).to include(user)
    end
  end
end

