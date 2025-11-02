# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw,
  :password,
  :password_confirmation,
  :email,
  :secret,
  :secret_key_base,
  :token,
  :jwt,
  :jti,
  :_key,
  :crypt,
  :salt,
  :certificate,
  :otp,
  :verification_code,
  :reset_password_token,
  :ssn,
  :cvv,
  :cvc,
  :authorization,
  :authenticity_token,
  :api_key,
  :api_secret,
  :access_token,
  :refresh_token
]
