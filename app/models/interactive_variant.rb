class InteractiveVariant < ApplicationRecord
  belongs_to :interactive

  validates :seed, presence: true, uniqueness: { scope: :interactive_id }

  def expected_answer
    payload['expected_answer'].to_s
  end

  def hidden_text
    payload['hidden_text']
  end

  def hint
    payload['hint']
  end

  def matches?(submission, kind: nil)
    return false if submission.to_s.strip.empty?

    case kind
    when 'password_crack'
      hash_value = payload['hash_value'].to_s.downcase
      algo = (payload['hash_algo'] || 'md5').to_s.downcase
      computed = compute_hash(submission.to_s, algo)
      computed == hash_value
    when 'xss_payload'
      # exact-match без приведения регистра — payload может быть case-sensitive
      submission.to_s.strip == expected_answer.strip
    when 'phishing_quiz'
      if payload['correct_markers'].is_a?(Array)
        submitted_set = submission.to_s.split(',').map { |s| s.strip.downcase }.reject(&:empty?).to_set
        expected_set = payload['correct_markers'].map { |s| s.to_s.strip.downcase }.to_set
        submitted_set == expected_set
      else
        return false if expected_answer.blank?
        submission.to_s.strip.downcase == expected_answer.strip.downcase
      end
    else
      return false if expected_answer.blank?
      submission.to_s.strip.downcase == expected_answer.strip.downcase
    end
  end

  private

  def compute_hash(input, algo)
    require 'digest'
    case algo
    when 'md5'    then Digest::MD5.hexdigest(input)
    when 'sha1'   then Digest::SHA1.hexdigest(input)
    when 'sha256' then Digest::SHA256.hexdigest(input)
    else ''
    end
  end
end
