require 'rails_helper'

RSpec.describe InteractiveVariant, type: :model do
  let(:interactive) do
    Interactive.create!(
      key: 'test.key', kind: 'find_text_in_html', category: 'dev_diving',
      title: 'T', description: 'd', xp_reward: 10, difficulty: 1
    )
  end

  describe 'validations' do
    it 'requires seed unique per interactive' do
      interactive.interactive_variants.create!(seed: 1, payload: {})
      duplicate = interactive.interactive_variants.build(seed: 1, payload: {})
      expect(duplicate).not_to be_valid
    end

    it 'allows same seed across different interactives' do
      i2 = Interactive.create!(
        key: 'test.other', kind: 'find_text_in_html', category: 'dev_diving',
        title: 'T2', description: 'd', xp_reward: 10, difficulty: 1
      )
      interactive.interactive_variants.create!(seed: 1, payload: {})
      expect(i2.interactive_variants.build(seed: 1, payload: {})).to be_valid
    end
  end

  describe '#matches?' do
    context 'default kind (string match)' do
      let(:variant) { interactive.interactive_variants.create!(seed: 1, payload: { 'expected_answer' => 'Kraken' }) }

      it 'matches exact case-insensitive' do
        expect(variant.matches?('kraken')).to be true
        expect(variant.matches?('KRAKEN')).to be true
        expect(variant.matches?('Kraken')).to be true
      end

      it 'matches with surrounding whitespace' do
        expect(variant.matches?('  kraken  ')).to be true
      end

      it 'does not match different string' do
        expect(variant.matches?('cthulhu')).to be false
      end

      it 'does not match empty submission' do
        expect(variant.matches?('')).to be false
        expect(variant.matches?(nil)).to be false
        expect(variant.matches?('   ')).to be false
      end

      it 'returns false if expected_answer is blank' do
        v = interactive.interactive_variants.create!(seed: 2, payload: { 'expected_answer' => '' })
        expect(v.matches?('anything')).to be false
      end
    end

    context 'password_crack kind' do
      let(:variant) do
        interactive.interactive_variants.create!(
          seed: 1,
          payload: {
            'expected_answer' => '123456',
            'hash_value' => 'e10adc3949ba59abbe56e057f20f883e', # md5('123456')
            'hash_algo' => 'md5'
          }
        )
      end

      it 'matches when MD5 of submission equals hash_value' do
        expect(variant.matches?('123456', kind: 'password_crack')).to be true
      end

      it 'does not match wrong password' do
        expect(variant.matches?('wrongpass', kind: 'password_crack')).to be false
      end

      it 'matches case-sensitive password' do
        expect(variant.matches?('123456', kind: 'password_crack')).to be true
      end

      it 'supports sha1 algo' do
        v = interactive.interactive_variants.create!(
          seed: 2,
          payload: {
            'expected_answer' => 'hello',
            'hash_value' => Digest::SHA1.hexdigest('hello'),
            'hash_algo' => 'sha1'
          }
        )
        expect(v.matches?('hello', kind: 'password_crack')).to be true
        expect(v.matches?('world', kind: 'password_crack')).to be false
      end

      it 'returns false for unknown algo' do
        v = interactive.interactive_variants.create!(
          seed: 3,
          payload: { 'expected_answer' => 'x', 'hash_value' => 'whatever', 'hash_algo' => 'bcrypt' }
        )
        expect(v.matches?('x', kind: 'password_crack')).to be false
      end
    end

    context 'xss_payload kind (case-sensitive exact)' do
      let(:variant) do
        interactive.interactive_variants.create!(
          seed: 1, payload: { 'expected_answer' => '<script>alert(1)</script>' }
        )
      end

      it 'matches exact payload' do
        expect(variant.matches?('<script>alert(1)</script>', kind: 'xss_payload')).to be true
      end

      it 'does NOT match different case' do
        expect(variant.matches?('<SCRIPT>alert(1)</SCRIPT>', kind: 'xss_payload')).to be false
      end

      it 'does not match approximate payload' do
        expect(variant.matches?('<script>alert(2)</script>', kind: 'xss_payload')).to be false
      end
    end

    context 'phishing_quiz kind with correct_markers (set match)' do
      let(:variant) do
        interactive.interactive_variants.create!(
          seed: 1,
          payload: {
            'expected_answer' => 'urgency,typo_domain,shortener',
            'correct_markers' => %w[urgency typo_domain shortener]
          }
        )
      end

      it 'matches markers in same order' do
        expect(variant.matches?('urgency,typo_domain,shortener', kind: 'phishing_quiz')).to be true
      end

      it 'matches markers in different order (set comparison)' do
        expect(variant.matches?('shortener,urgency,typo_domain', kind: 'phishing_quiz')).to be true
      end

      it 'matches with whitespace around items' do
        expect(variant.matches?(' urgency , typo_domain , shortener ', kind: 'phishing_quiz')).to be true
      end

      it 'matches case-insensitive' do
        expect(variant.matches?('URGENCY,Typo_Domain,SHORTENER', kind: 'phishing_quiz')).to be true
      end

      it 'does not match if extra marker selected' do
        expect(variant.matches?('urgency,typo_domain,shortener,generic_greeting', kind: 'phishing_quiz')).to be false
      end

      it 'does not match if marker missing' do
        expect(variant.matches?('urgency,typo_domain', kind: 'phishing_quiz')).to be false
      end

      it 'does not match empty submission' do
        expect(variant.matches?('', kind: 'phishing_quiz')).to be false
      end
    end

    context 'phishing_quiz kind WITHOUT correct_markers (single email select)' do
      let(:variant) do
        interactive.interactive_variants.create!(
          seed: 1, payload: { 'expected_answer' => 'email-3' }
        )
      end

      it 'falls back to default string match' do
        expect(variant.matches?('email-3', kind: 'phishing_quiz')).to be true
      end

      it 'does not match wrong email id' do
        expect(variant.matches?('email-1', kind: 'phishing_quiz')).to be false
      end
    end
  end

  describe 'payload accessors' do
    let(:variant) do
      interactive.interactive_variants.create!(
        seed: 1,
        payload: {
          'expected_answer' => 'foo',
          'hidden_text' => 'bar',
          'hint' => 'baz'
        }
      )
    end

    it 'reads expected_answer' do
      expect(variant.expected_answer).to eq('foo')
    end

    it 'reads hidden_text' do
      expect(variant.hidden_text).to eq('bar')
    end

    it 'reads hint' do
      expect(variant.hint).to eq('baz')
    end
  end
end
