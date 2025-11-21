require 'rails_helper'

RSpec.describe VerificationMailer, type: :mailer do
  describe '#send_verification_code' do
    it 'sends verification code email' do
      user = User.create!(
        email: "user2@example.com",
        password: "password123",
        email_verified: false
      )
      user.generate_verification_code!
      
      mail = VerificationMailer.send_verification_code(user)
      
      expect(mail.subject).to eq('Код подтверждения')
      expect(mail.to).to eq([user.email])
      expect(mail.text_part.body.to_s).to match(user.verification_code)
    end
  end
end

