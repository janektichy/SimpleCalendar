module Events
  class AssignSchedule
    def self.call(event:, input:)
      new(event, input).call
    end

    def initialize(event, input)
      @event = event
      @input = input
    end

    def call
      assign_form_state
      assign_schedule
    end

    private

    attr_reader :event, :input

    def assign_form_state
      event.repeat_event = input[:repeat_event]
      event.repeat_frequency = input[:repeat_frequency]
      event.event_date = input[:event_date]
      event.start_time = input[:start_time]
      event.end_time = input[:end_time]
    end

    def assign_schedule
      event_date = parse_event_date

      unless event_date
        event.errors.add(:starts_at, "date is required")
        return false
      end

      if event.all_day?
        event.starts_at = event_date.beginning_of_day
        event.ends_at = event_date.end_of_day
        return true
      end

      starts_at = parse_event_time(event_date, input[:start_time])
      ends_at = parse_event_time(event_date, input[:end_time])

      event.starts_at = starts_at
      event.ends_at = ends_at
      event.errors.add(:starts_at, "time is required") if starts_at.blank?
      event.errors.add(:ends_at, "time is required") if ends_at.blank?

      starts_at.present? && ends_at.present?
    end

    def parse_event_date
      value = input[:event_date].to_s
      return if value.blank?

      Date.iso8601(value)
    rescue Date::Error
      nil
    end

    def parse_event_time(date, value)
      raw_time = value.to_s
      return if raw_time.blank?

      Time.zone.parse("#{date} #{raw_time}")
    end
  end
end
