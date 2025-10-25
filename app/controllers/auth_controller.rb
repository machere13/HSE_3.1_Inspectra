class AuthController < WebController
  include JwtHelper
  def login; end
  def login_submit
    email = params[:email].to_s.strip
    password = params[:password]
    if email.blank? || password.blank?
      flash.now[:alert] = 'Email и пароль обязательны'
      return render :login, status: :unprocessable_entity
    end

    user = User.find_by(email: email)
    if user
      if user.authenticate(password)
        user.generate_verification_code!
        VerificationMailer.send_verification_code(user).deliver_now
        session[:pending_email] = user.email
        session[:last_verification_code_sent_at] = Time.current.to_i
        redirect_to verify_path(email: user.email), notice: 'Код отправлен на email'
      else
        flash.now[:alert] = 'Неверный пароль'
        render :login, status: :unauthorized
      end
    else
      user = User.new(email: email, password: password)
      if user.save
        user.generate_verification_code!
        VerificationMailer.send_verification_code(user).deliver_now
        session[:pending_email] = user.email
        session[:last_verification_code_sent_at] = Time.current.to_i
        redirect_to verify_path(email: user.email), notice: 'Проверьте email для подтверждения'
      else
        flash.now[:alert] = user.errors.full_messages.join(', ')
        render :login, status: :unprocessable_entity
      end
    end
  end
  def verify
    session[:pending_email] = params[:email] if params[:email].present?
    if (ts = session[:last_verification_code_sent_at]).present?
      wait = 60 - (Time.current.to_i - ts.to_i)
      @resend_wait_left = wait.positive? ? wait : 0
    else
      @resend_wait_left = 0
    end
  end
  def forgot; end
  def reset
    @token = params[:token]
  end

  def verify_submit
    email = params[:email].presence || params[:hidden_email].presence || params[:pending_email].presence
    code = params[:code].to_s.strip

    if email.blank? || code.blank?
      flash.now[:alert] = 'Email и код обязательны'
      @email = email
      return render :verify, status: :unprocessable_entity
    end

    user = User.find_by(email: email)
    unless user
      flash.now[:alert] = 'Пользователь не найден'
      @email = email
      return render :verify, status: :not_found
    end

    if user.verification_code_valid?(code)
      user.update!(verification_code: nil, verification_code_expires_at: nil)
      token = encode_token({ user_id: user.id })
      cookies[:token] = { value: token, httponly: true }
      redirect_to root_path, notice: 'Вход выполнен'
    else
      flash.now[:alert] = 'Неверный или истекший код'
      @email = email
      if (ts = session[:last_verification_code_sent_at]).present?
        wait = 60 - (Time.current.to_i - ts.to_i)
        @resend_wait_left = wait.positive? ? wait : 0
      else
        @resend_wait_left = 0
      end
      render :verify, status: :unauthorized
    end
  end

  def resend
    email = (params[:email].to_s.strip.presence || session[:pending_email].to_s.strip)

    if email.blank?
      flash[:alert] = 'Email обязателен'
      return redirect_to verify_path(email: email)
    end

    user = User.find_by(email: email)
    unless user
      flash[:alert] = 'Пользователь не найден'
      return redirect_to verify_path(email: email)
    end

    last = session[:last_verification_code_sent_at]
    if last && (Time.current.to_i - last.to_i) < 60
      wait = 60 - (Time.current.to_i - last.to_i)
      flash[:alert] = "Повторная отправка доступна через #{wait} сек"
      return redirect_to verify_path(email: email)
    end

    user.generate_verification_code!
    VerificationMailer.send_verification_code(user).deliver_now
    session[:last_verification_code_sent_at] = Time.current.to_i
    flash[:notice] = 'Код отправлен повторно'
    redirect_to verify_path(email: email)
  end

  def forgot_submit
    email = params[:email].to_s.strip
    if email.blank?
      flash.now[:alert] = 'Email обязателен'
      return render :forgot, status: :unprocessable_entity
    end

    user = User.find_by(email: email)
    if user
      if user.reset_password_requested_at && user.reset_password_requested_at > 60.seconds.ago
        flash[:alert] = 'Письмо уже отправлено, попробуйте позже'
        return redirect_to forgot_path
      end

      begin
        user.generate_reset_password_token!
        ResetPasswordMailer.with(user: user).reset_instructions.deliver_now
      rescue => e
        if Rails.env.development? || Rails.env.test?
          flash[:notice] = "Debug: письмо не отправлено (SMTP). URL: #{root_url}reset_password?token=#{user.reset_password_token}"
        else
          flash[:alert] = 'Не удалось отправить письмо'
        end
        return redirect_to forgot_path
      end
    end

    flash[:notice] = 'Если email существует, мы отправили ссылку для сброса'
    redirect_to forgot_path
  end

  def reset_submit
    token = params[:token].to_s
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    if token.blank? || password.blank? || password_confirmation.blank?
      flash.now[:alert] = 'Токен и пароли обязательны'
      @token = token
      return render :reset, status: :unprocessable_entity
    end

    if password.length < 8 || password.length > 64
      flash.now[:alert] = 'Пароль должен быть от 8 до 64 символов'
      @token = token
      return render :reset, status: :unprocessable_entity
    end

    user = User.find_by(reset_password_token: token)
    unless user
      flash.now[:alert] = 'Неверный токен'
      @token = token
      return render :reset, status: :unauthorized
    end
    unless user.reset_token_valid?(ttl_minutes: 30)
      flash.now[:alert] = 'Ссылка истекла'
      @token = token
      return render :reset, status: :unauthorized
    end

    user.password = password
    user.password_confirmation = password_confirmation
    if user.save
      user.clear_reset_password_token!
      redirect_to root_path, notice: 'Пароль обновлён'
    else
      flash.now[:alert] = user.errors.full_messages.join(', ')
      @token = token
      render :reset, status: :unprocessable_entity
    end
  end
end


