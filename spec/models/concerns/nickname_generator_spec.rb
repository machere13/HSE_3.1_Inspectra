require 'rails_helper'

RSpec.describe NicknameGenerator, type: :concern do
  let(:test_class) do
    Class.new do
      include NicknameGenerator
      attr_accessor :name
      
      def self.exists?(name:)
        false
      end
    end
  end
  
  let(:instance) { test_class.new }
  
  describe 'constants' do
    it 'should have CODE_METAPHOR_PREFIXES constant' do
      expect(NicknameGenerator::CODE_METAPHOR_PREFIXES).to be_an(Array)
      expect(NicknameGenerator::CODE_METAPHOR_PREFIXES).not_to be_empty
      expect(NicknameGenerator::CODE_METAPHOR_PREFIXES).to be_frozen
    end
    
    it 'should have CODE_METAPHOR_SUFFIXES constant' do
      expect(NicknameGenerator::CODE_METAPHOR_SUFFIXES).to be_an(Array)
      expect(NicknameGenerator::CODE_METAPHOR_SUFFIXES).not_to be_empty
      expect(NicknameGenerator::CODE_METAPHOR_SUFFIXES).to be_frozen
    end
    
    it 'should have valid prefixes' do
      prefixes = NicknameGenerator::CODE_METAPHOR_PREFIXES
      expect(prefixes).to include('Code', 'Bug', 'Syntax', 'Debug', 'Stack', 'Function', 'Class')
      expect(prefixes.all? { |p| p.is_a?(String) && !p.empty? }).to be true
    end
    
    it 'should have valid suffixes' do
      suffixes = NicknameGenerator::CODE_METAPHOR_SUFFIXES
      expect(suffixes).to include('Ninja', 'Master', 'Wizard', 'Hunter', 'Builder', 'Developer')
      expect(suffixes.all? { |s| s.is_a?(String) && !s.empty? }).to be true
    end
  end
  
  describe '#generate_code_metaphor_name' do
    it 'should return a string' do
      name = instance.generate_code_metaphor_name
      expect(name).to be_a(String)
      expect(name).not_to be_empty
    end
    
    it 'should generate names with correct format' do
      10.times do
        name = instance.generate_code_metaphor_name
        expect(name).to match(/\A[A-Z][a-zA-Z]+[A-Z][a-zA-Z]+\d{3,4}\z/)
      end
    end
    
    it 'should use prefixes from CODE_METAPHOR_PREFIXES' do
      prefixes = NicknameGenerator::CODE_METAPHOR_PREFIXES
      generated_prefixes = []
      
      50.times do
        name = instance.generate_code_metaphor_name
        prefix = prefixes.find { |p| name.start_with?(p) }
        generated_prefixes << prefix if prefix
      end
      
      expect(generated_prefixes.uniq.length).to be > 0
      expect(generated_prefixes.all? { |p| prefixes.include?(p) }).to be true
    end
    
    it 'should use suffixes from CODE_METAPHOR_SUFFIXES' do
      suffixes = NicknameGenerator::CODE_METAPHOR_SUFFIXES
      generated_suffixes = []
      
      50.times do
        name = instance.generate_code_metaphor_name
        suffix = suffixes.find { |s| name.include?(s) && name.end_with?("#{s}#{name.match(/\d+$/)[0]}") }
        generated_suffixes << suffix if suffix
      end
      
      expect(generated_suffixes.uniq.length).to be > 0
      expect(generated_suffixes.all? { |s| suffixes.include?(s) }).to be true
    end
    
    it 'should generate numbers in range 100-9999' do
      20.times do
        name = instance.generate_code_metaphor_name
        number = name.match(/\d+$/)[0].to_i
        expect(number).to be_between(100, 9999)
      end
    end
    
    it 'should generate different names on multiple calls' do
      names = 10.times.map { instance.generate_code_metaphor_name }
      expect(names.uniq.length).to be > 1
    end
  end
  
  describe '#generate_code_metaphor_name!' do
    context 'when name does not exist' do
      it 'should set the name attribute' do
        instance.generate_code_metaphor_name!
        expect(instance.name).not_to be_nil
        expect(instance.name).to be_a(String)
        expect(instance.name).not_to be_empty
      end
      
      it 'should generate a valid nickname format' do
        instance.generate_code_metaphor_name!
        expect(instance.name).to match(/\A[A-Z][a-zA-Z]+[A-Z][a-zA-Z]+\d{3,4}\z/)
      end
    end
    
    context 'when name already exists' do
      let(:existing_name) { 'CodeNinja1234' }
      
      before do
        allow(test_class).to receive(:exists?).with(name: existing_name).and_return(true)
        allow(test_class).to receive(:exists?).and_call_original
      end
      
      it 'should regenerate until unique name is found' do
        call_count = 0
        allow(instance).to receive(:generate_code_metaphor_name) do
          call_count += 1
          if call_count == 1
            existing_name
          else
            'UniqueName5678'
          end
        end
        
        allow(test_class).to receive(:exists?) do |name:|
          name == existing_name
        end
        
        instance.generate_code_metaphor_name!
        expect(instance.name).to eq('UniqueName5678')
        expect(call_count).to be > 1
      end
    end
  end
  
  describe 'integration with User model' do
    it 'should generate name when User is created without name' do
      user = User.new(email: 'test_nickname@example.com', password: 'password123')
      expect(user.name).to be_nil
      
      user.save!
      
      expect(user.name).not_to be_nil
      expect(user.name).to match(/\A[A-Z][a-zA-Z]+[A-Z][a-zA-Z]+\d{3,4}\z/)
    end
    
    it 'should not generate name when User has name' do
      user = User.new(email: 'test_nickname2@example.com', password: 'password123', name: 'CustomName')
      expect(user.name).to eq('CustomName')
      
      user.save!
      
      expect(user.name).to eq('CustomName')
    end
    
    it 'should generate unique names for multiple users' do
      users = []
      5.times do |i|
        user = User.create!(email: "test_nickname#{i}@example.com", password: 'password123')
        users << user
      end
      
      names = users.map(&:name)
      expect(names.uniq.length).to eq(5)
      
      users.each(&:destroy)
    end
  end
end

