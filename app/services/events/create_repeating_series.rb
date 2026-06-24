module Events
  class CreateRepeatingSeries
    OCCURRENCES_COUNT = 24

    def self.call(user:, base_event:, event_attributes:, input:)
      new(user, base_event, event_attributes, input).call
    end

    def initialize(user, base_event, event_attributes, input)
      @user = user
      @base_event = base_event
      @event_attributes = event_attributes
      @input = input
    end

    def call
      series = user.event_series.new(series_params)

      unless base_event.valid? && series.valid?
        merge_errors(base_event, series)
        return false
      end

      ActiveRecord::Base.transaction do
        series.save!
        build_repeated_events(series).each(&:save!)
      end

      true
    rescue ActiveRecord::RecordInvalid
      merge_errors(base_event, series)
      false
    end

    private

    attr_reader :user, :base_event, :event_attributes, :input

    def series_params
      {
        repeat_frequency: normalized_repeat_frequency,
        occurrences_count: OCCURRENCES_COUNT
      }
    end

    def normalized_repeat_frequency
      frequency = input[:repeat_frequency].to_s
      return frequency if EventSeries.repeat_frequencies.key?(frequency)

      "weekly"
    end

    def build_repeated_events(series)
      (1..series.occurrences_count).map do |step|
        starts_at = shifted_time(base_event.starts_at, series.repeat_frequency, step - 1)
        ends_at = shifted_time(base_event.ends_at, series.repeat_frequency, step - 1)

        user.events.new(
          event_attributes.merge(
            starts_at: starts_at,
            ends_at: ends_at,
            event_series: series
          )
        )
      end
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
  end
end
