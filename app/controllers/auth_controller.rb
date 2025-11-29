class AuthController < WebController
  include JwtHelper
  layout 'auth'
  def login; end
  def login_submit
    email = params[:email].to_s.strip
    password = params[:password]
    if email.blank? || password.blank?
      flash.now[:alert] = t('auth.flashes.email_and_password_required')
      return render :login, status: :unprocessable_entity
    end

    user = User.find_by(email: email)
    if user
      if user.authenticate(password)
        user.generate_verification_code!
        VerificationMailer.send_verification_code(user).deliver_now
        session[:pending_email] = user.email
        session[:last_verification_code_sent_at] = Time.current.to_i
        redirect_to verify_path(email: user.email), notice: t('auth.flashes.code_sent')
      else
        flash.now[:alert] = t('auth.flashes.wrong_password')
        render :login, status: :unauthorized
      end
    else
      user = User.new(email: email, password: password)
      if user.save
        user.generate_verification_code!
        VerificationMailer.send_verification_code(user).deliver_now
        session[:pending_email] = user.email
        session[:last_verification_code_sent_at] = Time.current.to_i
        redirect_to verify_path(email: user.email), notice: t('auth.flashes.check_email_for_verification')
      else
        flash.now[:alert] = user.errors.full_messages.join(', ')
        render :login, status: :unprocessable_entity
      end
    end
  end
  def verify
    session[:pending_email] = params[:email] if params[:email].present?
    if (ts = session[:last_verification_code_sent_at]).present?
      cooldown = AppConfig::Auth.resend_code_cooldown_seconds.to_i
      wait = cooldown - (Time.current.to_i - ts.to_i)
      @resend_wait_left = wait.positive? ? wait : 0
    else
      @resend_wait_left = 0
    end
  end
  def forgot; end
  def reset
    @token = params[:token]
    if current_user && @token.present?
      user = User.find_by(reset_password_token: @token)
      if user && user.id == current_user.id && user.reset_token_valid?
        redirect_to profile_path(token: @token)
        return
      end
    end
  end

  def verify_submit
    email = params[:email].presence || params[:hidden_email].presence || params[:pending_email].presence
    code = params[:code].to_s.strip

    if email.blank? || code.blank?
      flash.now[:alert] = t('auth.flashes.email_and_code_required')
      @email = email
      return render :verify, status: :unprocessable_entity
    end

    user = User.find_by(email: email)
    unless user
      flash.now[:alert] = t('auth.flashes.user_not_found')
      @email = email
      return render :verify, status: :not_found
    end

    if user.verification_code_valid?(code)
      user.verify_email!
      token = encode_token({ user_id: user.id })
      cookies[:token] = {
        value: token,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax,
        expires: AppConfig::JWT.token_ttl_hours.from_now
      }
      redirect_to root_path, notice: t('auth.flashes.login_success')
    else
      flash.now[:alert] = t('auth.flashes.invalid_or_expired_code')
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
      flash[:alert] = t('auth.flashes.email_required')
      return redirect_to verify_path(email: email)
    end

    user = User.find_by(email: email)
    unless user
      flash[:alert] = t('auth.flashes.user_not_found')
      return redirect_to verify_path(email: email)
    end

    last = session[:last_verification_code_sent_at]
    if last && (Time.current.to_i - last.to_i) < 60
      wait = 60 - (Time.current.to_i - last.to_i)
      flash[:alert] = t('auth.flashes.resend_wait', seconds: wait)
      return redirect_to verify_path(email: email)
    end

    user.generate_verification_code!
    VerificationMailer.send_verification_code(user).deliver_now
    session[:last_verification_code_sent_at] = Time.current.to_i
    flash[:notice] = t('auth.flashes.code_resent')
    redirect_to verify_path(email: email)
  end

  def forgot_submit
    email = params[:email].to_s.strip
    if email.blank?
      flash.now[:alert] = t('auth.flashes.email_required')
      return render :forgot, status: :unprocessable_entity
    end

    user = User.find_by(email: email)
    if user
      if user.reset_password_requested_at && user.reset_password_requested_at > AppConfig::Auth.resend_code_cooldown_seconds.ago
        flash[:alert] = t('auth.flashes.email_already_sent_try_later')
        return redirect_to forgot_path
      end

      user.generate_reset_password_token!
      ResetPasswordMailer.with(user: user).reset_instructions.deliver_now
    end

    flash[:notice] = t('auth.flashes.if_email_exists_sent_link')
    redirect_to forgot_path
  end

  def reset_submit
    token = params[:token].to_s
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    if token.blank? || password.blank? || password_confirmation.blank?
      flash.now[:alert] = t('auth.flashes.token_and_passwords_required')
      @token = token
      return render :reset, status: :unprocessable_entity
    end

    if password.length < 8 || password.length > 64
      flash.now[:alert] = t('auth.flashes.password_length_invalid')
      @token = token
      return render :reset, status: :unprocessable_entity
    end

    user = User.find_by(reset_password_token: token)
    unless user
      flash.now[:alert] = t('auth.flashes.invalid_token')
      @token = token
      return render :reset, status: :unauthorized
    end
    unless user.reset_token_valid?
      flash.now[:alert] = t('auth.flashes.link_expired')
      @token = token
      return render :reset, status: :unauthorized
    end

    user.password = password
    user.password_confirmation = password_confirmation
    if user.save
      user.clear_reset_password_token!
      if current_user && current_user.id == user.id
        redirect_to profile_path, notice: t('auth.flashes.password_updated')
      else
        redirect_to root_path, notice: t('auth.flashes.password_updated')
      end
    else
      flash.now[:alert] = user.errors.full_messages.join(', ')
      @token = token
      render :reset, status: :unprocessable_entity
    end
  end
end


