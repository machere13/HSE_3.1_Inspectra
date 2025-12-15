require 'rails_helper'

RSpec.describe Ability, type: :model do
  describe 'for super_admin' do
    let(:user) { User.create!(email: 'admin@example.com', password: 'password123', email_verified: true, role: :super_admin) }
    let(:ability) { Ability.new(user) }

    it 'should allow all actions' do
      expect(ability.can?(:manage, :all)).to be true
    end
  end

  describe 'for admin' do
    let(:user) { User.create!(email: 'admin@example.com', password: 'password123', email_verified: true, role: :admin) }
    let(:ability) { Ability.new(user) }

    it 'should allow managing weeks' do
      expect(ability.can?(:manage, Week)).to be true
    end

    it 'should allow reading admin panel' do
      expect(ability.can?(:read, :admin_panel)).to be true
    end

    it 'should allow reading users' do
      expect(ability.can?(:read, User)).to be true
    end
  end

  describe 'for moderator' do
    let(:user) { User.create!(email: 'moderator@example.com', password: 'password123', email_verified: true, role: :moderator) }
    let(:ability) { Ability.new(user) }

    it 'should allow reading and updating weeks' do
      expect(ability.can?(:read, Week)).to be true
      expect(ability.can?(:update, Week)).to be true
    end

    it 'should not allow managing weeks' do
      expect(ability.can?(:manage, Week)).to be false
    end
  end

  describe 'for regular user' do
    let(:user) { User.create!(email: 'user@example.com', password: 'password123', email_verified: true, role: :user) }
    let(:ability) { Ability.new(user) }

    it 'should allow reading weeks' do
      expect(ability.can?(:read, Week)).to be true
    end

    it 'should not allow updating weeks' do
      expect(ability.can?(:update, Week)).to be false
    end
  end

  describe 'for unverified user' do
    let(:user) { User.create!(email: 'user@example.com', password: 'password123', email_verified: false) }
    let(:ability) { Ability.new(user) }

    it 'should not allow any actions' do
      expect(ability.can?(:read, Week)).to be false
    end
  end

  describe 'for nil user' do
    let(:ability) { Ability.new(nil) }

    it 'should not allow any actions' do
      expect(ability.can?(:read, Week)).to be false
    end
  end
end

