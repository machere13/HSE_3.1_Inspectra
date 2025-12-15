require 'rails_helper'

RSpec.describe Title, type: :model do
  let(:title) { Title.new(name: 'Test Title') }

  describe 'validations' do
    it 'should be valid with valid attributes' do
      expect(title).to be_valid
    end

    it 'should require name' do
      title.name = nil
      expect(title).not_to be_valid
    end

    it 'should require unique name' do
      title.save!
      duplicate_title = Title.new(name: title.name)
      expect(duplicate_title).not_to be_valid
    end
  end

  describe 'associations' do
    it 'should have many user_titles' do
      title.save!
      user = User.create!(email: "test@example.com", password: "password123")
      user_title = title.user_titles.create!(user: user, earned_at: Time.current)
      expect(title.user_titles).to include(user_title)
    end

    it 'should have many users through user_titles' do
      title.save!
      user = User.create!(email: "test@example.com", password: "password123")
      title.user_titles.create!(user: user, earned_at: Time.current)
      expect(title.users).to include(user)
    end
  end
end

