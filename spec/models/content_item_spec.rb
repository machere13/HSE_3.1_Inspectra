require 'rails_helper'

RSpec.describe ContentItem, type: :model do
  let(:week) { Week.create!(number: 1, title: 'Test Week') }
  let(:content_item) { ContentItem.new(week: week, title: 'Test', kind: 'link', url: 'https://example.com') }

  describe 'validations' do
    it 'should be valid with valid attributes' do
      expect(content_item).to be_valid
    end

    it 'should require kind' do
      content_item.kind = nil
      expect(content_item).not_to be_valid
    end

    it 'should require kind to be in KINDS' do
      content_item.kind = 'invalid'
      expect(content_item).not_to be_valid
    end

    it 'should require week' do
      content_item.week = nil
      expect(content_item).not_to be_valid
    end

    it 'should require position to be non-negative' do
      content_item.position = -1
      expect(content_item).not_to be_valid
    end

    describe 'payload validation' do
      it 'should require url or file for image kind' do
        content_item.kind = 'image'
        content_item.url = nil
        expect(content_item).not_to be_valid
      end

      it 'should require url for link kind' do
        content_item.kind = 'link'
        content_item.url = nil
        expect(content_item).not_to be_valid
      end

      it 'should be valid with url for link kind' do
        content_item.kind = 'link'
        content_item.url = 'https://example.com'
        expect(content_item).to be_valid
      end
    end
  end

  describe 'associations' do
    it 'should belong to week' do
      content_item.save!
      expect(content_item.week).to eq(week)
    end

    it 'should have one attached file' do
      content_item.save!
      expect(content_item).to respond_to(:file)
    end
  end
end
