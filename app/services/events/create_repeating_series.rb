module Events
  class CreateRepeatingSeries
    MAX_OCCURRENCES_COUNT = 60

    def self.call(user:, base_event:, event_attributes:, input:, anchor_event: nil)
      new(user, base_event, event_attributes, input, anchor_event).call
    end

    def initialize(user, base_event, event_attributes, input, anchor_event)
      @user = user
      @base_event = base_event
      @event_attributes = event_attributes
      @input = input
      @anchor_event = anchor_event || base_event
    end

    def call
      events = build_repeated_events
      series = user.event_series.new(series_params(events.size))

      if repeat_ends_on.blank?
        base_event.errors.add(:repeat_ends_on, "is required")
      elsif repeat_ends_on < Time.zone.today
        base_event.errors.add(:repeat_ends_on, "cannot be in the past")
      end

      unless events.all?(&:valid?) && series.valid?
        merge_errors(base_event, series)
        return false
      end

      ActiveRecord::Base.transaction do
        series.save!
        events.each do |event|
          event.event_series = series
          event.save!
        end
      end

      true
    rescue ActiveRecord::RecordInvalid
      merge_errors(base_event, series)
      false
    end

    private

    attr_reader :user, :base_event, :event_attributes, :input, :anchor_event

    def series_params(occurrences_count)
      {
        repeat_frequency: normalized_repeat_frequency,
        repeat_ends_on: repeat_ends_on,
        occurrences_count: occurrences_count
      }
    end

    def repeat_ends_on
      @repeat_ends_on ||= parse_repeat_ends_on
    end

    def parse_repeat_ends_on
      value = input_value(:repeat_ends_on).to_s
      return if value.blank?

      Date.iso8601(value)
    rescue Date::Error
      nil
    end

    def normalized_repeat_frequency
      frequency = input_value(:repeat_frequency).to_s
      return frequency if EventSeries.repeat_frequencies.key?(frequency)

      "weekly"
    end

    def build_repeated_events
      return [] if repeat_ends_on.blank? || anchor_event.starts_at.blank? || anchor_event.ends_at.blank?

      events = []

      (0...MAX_OCCURRENCES_COUNT).each do |step|
        starts_at = shifted_time(anchor_event.starts_at, normalized_repeat_frequency, step)
        break if starts_at.to_date > repeat_ends_on

        ends_at = shifted_time(anchor_event.ends_at, normalized_repeat_frequency, step)

        events << Event.new(
          event_attributes.merge(
            user: user,
            starts_at: starts_at,
            ends_at: ends_at
          )
        )
      end

      events
    end

    def shifted_time(value, frequency, step)
      return value if step.zero?

      case frequency
      when "daily" then value + step.days
      when "weekly" then value + step.weeks
      else value + step.months
      end
    end

    def merge_errors(event, series)
      series.errors.full_messages.each do |message|
        event.errors.add(:base, message)
      end
    end

    def input_value(key)
      return input[key.to_s] if input.key?(key.to_s)

      input[key]
    end
  end
end
