require 'rails_helper'

RSpec.describe UserTitle, type: :model do
  let(:user) { User.create!(email: "test@example.com", password: "password123") }
  let(:title) { Title.create!(name: 'Test Title') }
  let(:user_title) { UserTitle.new(user: user, title: title, earned_at: Time.current) }

  describe 'validations' do
    it 'should be valid with valid attributes' do
      expect(user_title).to be_valid
    end

    it 'should require earned_at' do
      user_title.earned_at = nil
      expect(user_title).not_to be_valid
    end

    it 'should be unique per user and title' do
      user_title.save!
      duplicate = UserTitle.new(user: user, title: title, earned_at: Time.current)
      expect(duplicate).not_to be_valid
    end
  end

  describe 'associations' do
    it 'should belong to user' do
      user_title.save!
      expect(user_title.user).to eq(user)
    end

    it 'should belong to title' do
      user_title.save!
      expect(user_title.title).to eq(title)
    end
  end
end

