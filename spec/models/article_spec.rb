require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:week) { Week.create!(number: 1, title: 'Test Week') }
  let(:article) { Article.new(week: week, title: 'Test Article', body: 'Test body') }

  describe 'validations' do
    it 'should be valid with valid attributes' do
      expect(article).to be_valid
    end

    it 'should require title' do
      article.title = nil
      expect(article).not_to be_valid
    end

    it 'should require body' do
      article.body = nil
      expect(article).not_to be_valid
    end
  end

  describe 'associations' do
    it 'should belong to week' do
      article.save!
      expect(article.week).to eq(week)
    end

    it 'should have many content_items' do
      article.save!
      content_item = week.content_items.create!(
        title: 'Test',
        kind: 'link',
        url: 'https://example.com',
        article_id: article.id
      )
      expect(article.content_items).to include(content_item)
    end
  end
end
