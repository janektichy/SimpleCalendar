class User < ApplicationRecord
  # Handles password hashing and authentication helpers
  has_secure_password

  has_many :events, dependent: :destroy
  has_many :event_series, dependent: :destroy

  # Basic email validation keeps credentials clean and unique
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Password length keeps brute-force protection reasonable without complexity rules
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :default_upcoming_days, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 14 }
  validates :default_calendar_view, inclusion: { in: %w[month week] }

  before_validation :normalize_email

  private

  # Downcases and strips email so uniqueness works regardless of user input
  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end
end
