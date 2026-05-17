require 'rails_helper'

RSpec.describe Interactive, type: :model do
  describe 'validations' do
    let(:base) do
      {
        key: 'cat.x', kind: 'find_text_in_html', category: 'dev_diving',
        title: 'T', xp_reward: 50, difficulty: 1
      }
    end

    it 'requires key, title, category, kind' do
      expect(Interactive.new(base)).to be_valid
      expect(Interactive.new(base.merge(key: nil))).not_to be_valid
      expect(Interactive.new(base.merge(title: nil))).not_to be_valid
      expect(Interactive.new(base.merge(category: nil))).not_to be_valid
      expect(Interactive.new(base.merge(kind: nil))).not_to be_valid
    end

    it 'enforces unique key' do
      Interactive.create!(base)
      duplicate = Interactive.new(base)
      expect(duplicate).not_to be_valid
    end

    it 'rejects unknown kind' do
      expect(Interactive.new(base.merge(kind: 'wat'))).not_to be_valid
    end

    it 'rejects unknown category' do
      expect(Interactive.new(base.merge(category: 'wat'))).not_to be_valid
    end

    it 'allows all KIND values' do
      Interactive::KINDS.each do |k|
        i = Interactive.new(base.merge(key: "key.#{k}", kind: k))
        expect(i).to be_valid, "expected kind=#{k} to be valid"
      end
    end

    it 'allows all CATEGORY values' do
      Interactive::CATEGORIES.each do |c|
        i = Interactive.new(base.merge(key: "key.#{c}", category: c))
        expect(i).to be_valid
      end
    end

    it 'rejects negative xp_reward' do
      expect(Interactive.new(base.merge(xp_reward: -5))).not_to be_valid
    end
  end

  describe '#variant_for(user)' do
    let(:interactive) do
      Interactive.create!(
        key: 'x', kind: 'find_text_in_html', category: 'dev_diving',
        title: 'T', xp_reward: 10, difficulty: 1
      )
    end
    let!(:v1) { interactive.interactive_variants.create!(seed: 1, payload: { 'expected_answer' => 'a' }) }
    let!(:v2) { interactive.interactive_variants.create!(seed: 2, payload: { 'expected_answer' => 'b' }) }
    let!(:v3) { interactive.interactive_variants.create!(seed: 3, payload: { 'expected_answer' => 'c' }) }

    it 'returns deterministic variant based on user.id % count' do
      u3 = User.create!(email: 'u3@x.x', password: 'password123', email_verified: true)
      u6 = User.create!(email: 'u6@x.x', password: 'password123', email_verified: true)
      expect(interactive.variant_for(u3)).to eq(interactive.variant_for(u3))
    end

    it 'returns nil when no variants' do
      empty = Interactive.create!(
        key: 'empty', kind: 'find_text_in_html', category: 'dev_diving',
        title: 'T', xp_reward: 10, difficulty: 1
      )
      u = User.create!(email: 'u@x.x', password: 'password123', email_verified: true)
      expect(empty.variant_for(u)).to be_nil
    end

    it 'returns the same variant for the same user across calls' do
      u = User.create!(email: 'unique@x.x', password: 'password123', email_verified: true)
      first = interactive.variant_for(u)
      second = interactive.variant_for(u)
      expect(first.id).to eq(second.id)
    end

    it 'distributes users across all variants' do
      users = 30.times.map do |i|
        User.create!(email: "spread_#{i}@x.x", password: 'password123', email_verified: true)
      end
      seeds = users.map { |u| interactive.variant_for(u).seed }.uniq.sort
      expect(seeds).to eq([1, 2, 3])
    end
  end
end
