class User < ApplicationRecord
  # Handles password hashing and authentication helpers
  has_secure_password

  # Basic email validation keeps credentials clean and unique
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Password length keeps brute-force protection reasonable without complexity rules
  validates :password, length: { minimum: 8 }, allow_nil: true

  before_validation :normalize_email

  private

  # Downcases and strips email so uniqueness works regardless of user input
  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end
end
