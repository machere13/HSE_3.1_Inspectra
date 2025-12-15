require 'rails_helper'

RSpec.describe ResetPasswordMailer, type: :mailer do
  describe '#reset_instructions' do
    let(:user) do
      user = User.create!(email: 'test@example.com', password: 'password123')
      user.generate_reset_password_token!
      user
    end

    it 'sends reset password email' do
      mail = ResetPasswordMailer.with(user: user).reset_instructions
      
      expect(mail.subject).to eq('Сброс пароля')
      expect(mail.to).to eq([user.email])
      expect(mail.text_part.body.to_s).to include(user.reset_password_token)
    end

    it 'includes reset URL' do
      mail = ResetPasswordMailer.with(user: user).reset_instructions
      expect(mail.text_part.body.to_s).to include('reset_password')
    end
  end
end

