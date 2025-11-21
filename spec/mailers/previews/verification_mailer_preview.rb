class VerificationMailerPreview < ActionMailer::Preview
  def send_verification_code
    VerificationMailer.send_verification_code
  end
end

