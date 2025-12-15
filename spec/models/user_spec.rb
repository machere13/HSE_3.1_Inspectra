require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.new(email: "test@example.com", password: "password123") }

  describe 'validations' do
    it 'should be valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'should require email' do
      user.email = nil
      expect(user).not_to be_valid
    end

    it 'should require unique email' do
      user.save!
      duplicate_user = User.new(email: user.email, password: "password123")
      expect(duplicate_user).not_to be_valid
    end

    it 'should require valid email format' do
      user.email = 'invalid_email'
      expect(user).not_to be_valid
    end

    it 'should require password length between min and max' do
      user.password = '1234567' # меньше минимума
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it 'should have many user_achievements' do
      user.save!
      achievement = Achievement.create!(
        name: "Test",
        category: "general",
        progress_type: "total_interactives",
        progress_target: 10
      )
      user_achievement = user.user_achievements.create!(achievement: achievement, progress: 5)
      expect(user.user_achievements).to include(user_achievement)
    end

    it 'should have many achievements through user_achievements' do
      user.save!
      achievement = Achievement.create!(
        name: "Test",
        category: "general",
        progress_type: "total_interactives",
        progress_target: 10
      )
      user.user_achievements.create!(achievement: achievement, progress: 5)
      expect(user.achievements).to include(achievement)
    end

    it 'should have many user_titles' do
      user.save!
      title = Title.create!(name: "Test Title")
      user_title = user.user_titles.create!(title: title, earned_at: Time.current)
      expect(user.user_titles).to include(user_title)
    end

    it 'should belong to current_title' do
      user.save!
      title = Title.create!(name: "Test Title")
      user.update!(current_title: title)
      expect(user.current_title).to eq(title)
    end
  end

  describe '#generate_verification_code!' do
    it 'should generate a 6-digit code' do
      user.save!
      user.generate_verification_code!
      expect(user.verification_code).to match(/\A\d{6}\z/)
    end

    it 'should set expiration time' do
      user.save!
      user.generate_verification_code!
      expect(user.verification_code_expires_at).to be > Time.current
    end
  end

  describe '#verification_code_valid?' do
    it 'should return true for valid code' do
      user.save!
      user.generate_verification_code!
      expect(user.verification_code_valid?(user.verification_code)).to be true
    end

    it 'should return false for invalid code' do
      user.save!
      user.generate_verification_code!
      expect(user.verification_code_valid?('000000')).to be false
    end

    it 'should return false for expired code' do
      user.save!
      user.generate_verification_code!
      user.update_column(:verification_code_expires_at, 1.hour.ago)
      expect(user.verification_code_valid?(user.verification_code)).to be false
    end
  end

  describe '#verify_email!' do
    it 'should set email_verified to true' do
      user.save!
      user.verify_email!
      expect(user.email_verified?).to be true
    end

    it 'should clear verification code' do
      user.save!
      user.generate_verification_code!
      user.verify_email!
      expect(user.verification_code).to be_nil
    end
  end

  describe '#completed_achievements' do
    it 'should return only completed achievements' do
      user.save!
      achievement = Achievement.create!(
        name: "Test",
        category: "general",
        progress_type: "total_interactives",
        progress_target: 10
      )
      completed = user.user_achievements.create!(
        achievement: achievement,
        progress: 10,
        completed_at: Time.current
      )
      in_progress = user.user_achievements.create!(
        achievement: Achievement.create!(
          name: "Test2",
          category: "general",
          progress_type: "total_interactives",
          progress_target: 10
        ),
        progress: 5
      )
      expect(user.completed_achievements).to include(completed)
      expect(user.completed_achievements).not_to include(in_progress)
    end
  end

  describe '#has_title?' do
    it 'should return true if user has title' do
      user.save!
      title = Title.create!(name: "Test Title")
      user.user_titles.create!(title: title, earned_at: Time.current)
      expect(user.has_title?(title)).to be true
    end

    it 'should return false if user does not have title' do
      user.save!
      title = Title.create!(name: "Test Title")
      expect(user.has_title?(title)).to be false
    end
  end

  describe '#select_title!' do
    it 'should set current_title if user has title' do
      user.save!
      title = Title.create!(name: "Test Title")
      user.user_titles.create!(title: title, earned_at: Time.current)
      user.select_title!(title)
      expect(user.current_title).to eq(title)
    end

    it 'should raise ArgumentError if user does not have title' do
      user.save!
      title = Title.create!(name: "Test Title")
      expect { user.select_title!(title) }.to raise_error(ArgumentError)
    end
  end

  describe '#generate_reset_password_token!' do
    it 'should generate reset password token' do
      user.save!
      user.generate_reset_password_token!
      expect(user.reset_password_token).to be_present
    end

    it 'should set reset_password_requested_at' do
      user.save!
      user.generate_reset_password_token!
      expect(user.reset_password_requested_at).to be_present
    end
  end

  describe '#reset_token_valid?' do
    it 'should return true for valid token' do
      user.save!
      user.generate_reset_password_token!
      expect(user.reset_token_valid?).to be true
    end

    it 'should return false for expired token' do
      user.save!
      user.generate_reset_password_token!
      user.update_column(:reset_password_sent_at, 2.hours.ago)
      expect(user.reset_token_valid?).to be false
    end
  end

  describe 'roles' do
    it 'should have user role by default' do
      user.save!
      expect(user.user?).to be true
    end

    it 'should support admin role' do
      user.save!
      user.update!(role: :admin)
      expect(user.admin?).to be true
    end
  end
end
