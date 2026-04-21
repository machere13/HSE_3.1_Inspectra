class ErrorReport < ApplicationRecord
  validates :message, presence: true, length: { maximum: 20_000 }
  validates :page_url, length: { maximum: 2_048 }, allow_blank: true
  validates :status_code, length: { maximum: 16 }, allow_blank: true
  validates :reporter_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
