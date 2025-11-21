require 'rails_helper'

RSpec.describe AchievementService, type: :service do
  let(:user) { User.create!(email: "test@example.com", password: "password123") }
  let(:service) { AchievementService.new(user) }
  
  let!(:interactive_achievement) do
    Achievement.create!(
      name: "Интерактивное достижение",
      description: "Пройдите интерактив",
      category: "general",
      progress_type: "total_interactives",
      progress_target: 5
    )
  end
  
  let!(:consecutive_achievement) do
    Achievement.create!(
      name: "Достижение по дням",
      description: "Просматривайте контент подряд",
      category: "content_viewing",
      progress_type: "consecutive_days",
      progress_target: 7
    )
  end

  describe '#check_achievements_for_interactive_completion' do
    it 'should create user achievement when checking interactive completion' do
      service.check_achievements_for_interactive_completion
      
      user_achievement = user.user_achievements.find_by(achievement: interactive_achievement)
      expect(user_achievement).not_to be_nil
      expect(user_achievement.progress).to eq(1)
    end

    it 'should increment progress for interactive achievements' do
      service.check_achievements_for_interactive_completion
      service.check_achievements_for_interactive_completion
      
      user_achievement = user.user_achievements.find_by(achievement: interactive_achievement)
      expect(user_achievement.progress).to eq(2)
    end

    it 'should complete achievement when target is reached' do
      5.times { service.check_achievements_for_interactive_completion }
      
      user_achievement = user.user_achievements.find_by(achievement: interactive_achievement)
      expect(user_achievement.completed?).to be true
      expect(user_achievement.completed_at).not_to be_nil
    end
  end

  describe '#check_achievements_for_consecutive_days' do
    it 'should update progress for consecutive days' do
      service.check_achievements_for_consecutive_days(5)
      
      user_achievement = user.user_achievements.find_by(achievement: consecutive_achievement)
      expect(user_achievement).not_to be_nil
      expect(user_achievement.progress).to eq(5)
    end

    it 'should complete consecutive days achievement when target is reached' do
      service.check_achievements_for_consecutive_days(7)
      
      user_achievement = user.user_achievements.find_by(achievement: consecutive_achievement)
      expect(user_achievement.completed?).to be true
    end

    it 'should not complete achievement when target is not reached' do
      service.check_achievements_for_consecutive_days(3)
      
      user_achievement = user.user_achievements.find_by(achievement: consecutive_achievement)
      expect(user_achievement.completed?).to be false
      expect(user_achievement.completed_at).to be_nil
    end
  end
end

