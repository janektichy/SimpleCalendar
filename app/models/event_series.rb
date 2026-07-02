class EventSeries < ApplicationRecord
  belongs_to :user
  has_one :event, dependent: :destroy

  enum :repeat_frequency, { daily: "daily", weekly: "weekly", monthly: "monthly" }

  validates :repeat_frequency, presence: true
  validates :repeat_ends_on, presence: true
  validates :occurrences_count, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 60 }
end
