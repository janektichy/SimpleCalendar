module Events
  class ExpandRepeatingEvents
    MAX_OCCURRENCES_COUNT = 60

    def self.call(events:, range_start:, range_end:)
      new(events, range_start, range_end).call
    end

    def initialize(events, range_start, range_end)
      @events = events
      @range_start = range_start
      @range_end = range_end
    end

    def call
      events.flat_map { |event| occurrences_for(event) }
            .select { |event| event.starts_at <= range_end && event.ends_at >= range_start }
            .sort_by(&:starts_at)
    end

    private

    attr_reader :events, :range_start, :range_end

    def occurrences_for(event)
      return [ event ] unless event.event_series.present?

      series = event.event_series
      occurrences = []

      (0...MAX_OCCURRENCES_COUNT).each do |step|
        starts_at = shifted_time(event.starts_at, series.repeat_frequency, step)
        break if starts_at.to_date > series.repeat_ends_on

        ends_at = shifted_time(event.ends_at, series.repeat_frequency, step)
        next if starts_at > range_end || ends_at < range_start

        occurrences << VirtualOccurrence.new(
          event,
          starts_at: starts_at,
          ends_at: ends_at,
          occurrence_key: "#{event.id}-#{starts_at.to_date.iso8601}"
        )
      end

      occurrences
    end

    def shifted_time(value, frequency, step)
      return value if step.zero?

      case frequency
      when "daily" then value + step.days
      when "weekly" then value + step.weeks
      else value + step.months
      end
    end
  end
end
