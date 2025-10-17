class Api::V1::AuthController < ApplicationController
  include JwtHelper

  def login_or_register
    email = params[:email]
    password = params[:password]

    if email.blank? || password.blank?
      return render json: { error: 'Email и пароль обязательны' }, status: :bad_request
    end

    user = User.find_by(email: email)

    if user
      if user.authenticate(password)
        user.generate_verification_code!
        VerificationMailer.send_verification_code(user).deliver_now
        
        render json: { 
          message: 'Код подтверждения отправлен на email',
          requires_verification: true,
          email: user.email,
          verification_code: user.verification_code
        }, status: :ok
      else
        render json: { error: 'Неверный пароль' }, status: :unauthorized
      end
    else
      user = User.new(email: email, password: password)
      
      if user.save
        user.generate_verification_code!
        VerificationMailer.send_verification_code(user).deliver_now
        
        render json: {
          message: 'Пользователь зарегистрирован. Проверьте email для подтверждения.',
          requires_verification: true,
          email: user.email,
          verification_code: user.verification_code
        }, status: :created
      else
        render json: { 
          error: 'Ошибка регистрации',
          details: user.errors.full_messages 
        }, status: :unprocessable_entity
      end
    end
  end

  def verify_email
    email = params[:email]
    code = params[:code]

    if email.blank? || code.blank?
      return render json: { error: 'Email и код обязательны' }, status: :bad_request
    end

    user = User.find_by(email: email)
    
    unless user
      return render json: { error: 'Пользователь не найден' }, status: :not_found
    end

    if user.verification_code_valid?(code)
      user.verify_email!
      token = encode_token({ user_id: user.id })
      
      render json: {
        message: 'Email успешно подтвержден',
        token: token,
        user: {
          id: user.id,
          email: user.email
        }
      }, status: :ok
    else
      render json: { error: 'Неверный или истекший код' }, status: :unauthorized
    end
  end

  def resend_verification_code
    email = params[:email]

    if email.blank?
      return render json: { error: 'Email обязателен' }, status: :bad_request
    end

    user = User.find_by(email: email)
    
    unless user
      return render json: { error: 'Пользователь не найден' }, status: :not_found
    end

    if user.email_verified?
      return render json: { error: 'Email уже подтвержден' }, status: :bad_request
    end

    user.generate_verification_code!
    VerificationMailer.send_verification_code(user).deliver_now

    render json: {
      message: 'Код подтверждения отправлен повторно',
      verification_code: user.verification_code
    }, status: :ok
  end

  def me
    require_auth
    return unless logged_in?

    render json: {
      user: {
        id: current_user.id,
        email: current_user.email
      }
    }, status: :ok
  end

  def supported_email_domains
    render json: {
      supported_domains: SmtpConfigService.supported_domains,
      message: 'Поддерживаемые почтовые домены для регистрации'
    }, status: :ok
  end

  def forgot_password
    email = params[:email]
    return render json: { error: 'Email обязателен' }, status: :bad_request if email.blank?

    user = User.find_by(email: email)
    if user
      if user.reset_password_requested_at && user.reset_password_requested_at > 60.seconds.ago
        return render json: { error: 'Письмо уже отправлено, попробуйте позже' }, status: :too_many_requests
      end

      user.generate_reset_password_token!
      begin
        ResetPasswordMailer.with(user: user).reset_instructions.deliver_now
      rescue => e
        if Rails.env.development? || Rails.env.test?
          return render json: {
            message: 'Debug: письмо не отправлено (SMTP)',
            reset_token: user.reset_password_token,
            reset_url: root_url + "reset_password?token=#{user.reset_password_token}",
            error: e.class.name
          }, status: :ok
        else
          return render json: { error: 'Не удалось отправить письмо' }, status: :service_unavailable
        end
      end
    end

    render json: { message: 'Если email существует, мы отправили ссылку для сброса' }, status: :ok
  end

  def reset_password
    token = params[:token]
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    if token.blank? || password.blank? || password_confirmation.blank?
      return render json: { error: 'Токен и пароли обязательны' }, status: :bad_request
    end

    if password.length < 8 || password.length > 64
      return render json: { error: 'Пароль должен быть от 8 до 64 символов' }, status: :unprocessable_entity
    end

    user = User.find_by(reset_password_token: token)
    return render json: { error: 'Неверный токен' }, status: :unauthorized unless user
    return render json: { error: 'Ссылка истекла' }, status: :unauthorized unless user.reset_token_valid?(ttl_minutes: 30)

    user.password = password
    user.password_confirmation = password_confirmation
    if user.save
      user.clear_reset_password_token!
      token_jwt = encode_token({ user_id: user.id })
      render json: { message: 'Пароль обновлён', token: token_jwt }, status: :ok
    else
      render json: { error: 'Не удалось обновить пароль', details: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
