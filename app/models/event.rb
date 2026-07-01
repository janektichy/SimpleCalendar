class Event < ApplicationRecord
  COLORS = %w[white slate blue emerald amber rose violet cyan lime orange indigo].freeze

  attr_accessor :repeat_event, :repeat_frequency, :repeat_ends_on, :event_date, :start_time, :end_time

  belongs_to :user
  belongs_to :event_series, optional: true

  validates :title, presence: true, length: { maximum: 100 }
  validates :starts_at, :ends_at, presence: true
  validates :color, inclusion: { in: COLORS }
  validate :ends_at_after_starts_at

  scope :chronological, -> { order(:starts_at) }

  private

  def ends_at_after_starts_at
    return if starts_at.blank? || ends_at.blank?
    return if ends_at > starts_at

    errors.add(:ends_at, "must be later than the start time")
  end
end
