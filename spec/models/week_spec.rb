require 'rails_helper'

RSpec.describe Week, type: :model do
  let(:week) { Week.new(number: 1, title: 'Test Week', description: 'Test') }

  describe 'validations' do
    it 'should be valid with valid attributes' do
      expect(week).to be_valid
    end

    it 'should require number' do
      week = Week.new(title: 'Test Week')
      week.number = nil
      week.define_singleton_method(:apply_default_visibility_window) {}
      week.valid?
      expect(week.errors[:number]).to be_present
    end

    it 'should require unique number' do
      week.save!
      duplicate_week = Week.new(number: week.number, title: 'Another Week')
      expect(duplicate_week).not_to be_valid
    end

    it 'should require number between 1 and 24' do
      week.number = 0
      expect(week).not_to be_valid
      week.number = 25
      expect(week).not_to be_valid
    end

    it 'should require title' do
      week.title = nil
      expect(week).not_to be_valid
    end
  end

  describe 'associations' do
    it 'should have many articles' do
      week.save!
      article = week.articles.create!(title: 'Test Article', body: 'Test body')
      expect(week.articles).to include(article)
    end

    it 'should have many content_items' do
      week.save!
      content_item = week.content_items.create!(
        title: 'Test',
        kind: 'link',
        url: 'https://example.com'
      )
      expect(week.content_items).to include(content_item)
    end
  end

  describe 'scopes' do
    describe '.visible_now' do
      it 'should return weeks that are published and not expired' do
        Week.skip_callback(:create, :after, :create_next_week_if_needed)
        
        begin
          # Удаляем недели если они уже существуют
          Week.where(number: [1, 2, 3]).destroy_all
          
          visible_week = Week.create!(
            number: 1,
            title: 'Visible',
            published_at: 1.day.ago,
            expires_at: 1.day.from_now
          )
          
          expired_week = Week.new(
            number: 2,
            title: 'Expired',
            published_at: 1.day.ago,
            expires_at: 1.day.from_now
          )
          expired_week.save(validate: false)
          Week.where(id: expired_week.id).update_all(
            published_at: 2.days.ago,
            expires_at: 1.day.ago
          )
          expired_week.reload
          
          future_week = Week.create!(
            number: 3,
            title: 'Future',
            published_at: 1.day.from_now,
            expires_at: 2.days.from_now
          )

          visible_weeks = Week.visible_now
          expect(visible_weeks).to include(visible_week)
          expect(visible_weeks).not_to include(expired_week)
          expect(visible_weeks).not_to include(future_week)
        ensure
          # Восстанавливаем callback
          Week.set_callback(:create, :after, :create_next_week_if_needed)
        end
      end
    end
  end

  describe '#visible_now?' do
    it 'should return true for visible week' do
      week.published_at = 1.day.ago
      week.expires_at = 1.day.from_now
      expect(week.visible_now?).to be true
    end

    it 'should return false for expired week' do
      week.published_at = 2.days.ago
      week.expires_at = 1.day.ago
      expect(week.visible_now?).to be false
    end

    it 'should return false for future week' do
      week.published_at = 1.day.from_now
      week.expires_at = 2.days.from_now
      expect(week.visible_now?).to be false
    end
  end

  describe '#expired?' do
    it 'should return true for expired week' do
      week.expires_at = 1.day.ago
      expect(week.expired?).to be true
    end

    it 'should return false for active week' do
      week.expires_at = 1.day.from_now
      expect(week.expired?).to be false
    end
  end

  describe '#time_left' do
    it 'should return formatted time remaining' do
      week.expires_at = 2.hours.from_now
      time_left = week.time_left
      expect(time_left).to match(/\A\d{2}:\d{2}:\d{2}\z/)
    end

    it 'should return 00:00:00 if expired' do
      week.expires_at = 1.day.ago
      expect(week.time_left).to eq('00:00:00')
    end
  end

  describe '#to_param' do
    it 'should return number as string' do
      week.number = 5
      expect(week.to_param).to eq('5')
    end
  end

  describe 'callbacks' do
    describe 'apply_default_visibility_window' do
      it 'should set published_at and expires_at on create' do
        week.save!
        expect(week.published_at).to be_present
        expect(week.expires_at).to be_present
      end
    end
  end
end
