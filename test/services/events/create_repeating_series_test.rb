require "test_helper"

module Events
  class CreateRepeatingSeriesTest < ActiveSupport::TestCase
    test "creates weekly events through inclusive repeat end date" do
      user = users(:one)
      event = user.events.new(title: "Planning", color: "blue")
      input = {
        event_date: "2026-07-01",
        start_time: "09:00",
        end_time: "10:00",
        repeat_frequency: "weekly",
        repeat_ends_on: "2026-07-15"
      }
      AssignSchedule.call(event: event, input: input)

      result = CreateRepeatingSeries.call(
        user: user,
        base_event: event,
        event_attributes: { title: "Planning", description: nil, all_day: false, color: "blue" },
        input: input
      )

      assert result
      series = user.event_series.order(:created_at).last
      assert_equal Date.new(2026, 7, 15), series.repeat_ends_on
      assert_equal 3, series.occurrences_count
      assert_equal [ Date.new(2026, 7, 1), Date.new(2026, 7, 8), Date.new(2026, 7, 15) ], series.events.order(:starts_at).map { |created_event| created_event.starts_at.to_date }
    end

    test "does not create an occurrence after repeat end date" do
      user = users(:one)
      event = user.events.new(title: "Planning", color: "blue")
      input = {
        event_date: "2026-07-01",
        start_time: "09:00",
        end_time: "10:00",
        repeat_frequency: "weekly",
        repeat_ends_on: "2026-07-14"
      }
      AssignSchedule.call(event: event, input: input)

      result = CreateRepeatingSeries.call(
        user: user,
        base_event: event,
        event_attributes: { title: "Planning", description: nil, all_day: false, color: "blue" },
        input: input
      )

      assert result
      series = user.event_series.order(:created_at).last
      assert_equal 2, series.occurrences_count
      assert_equal [ Date.new(2026, 7, 1), Date.new(2026, 7, 8) ], series.events.order(:starts_at).map { |created_event| created_event.starts_at.to_date }
    end

    test "allows repeat end date with only the anchor occurrence" do
      user = users(:one)
      event = user.events.new(title: "Planning", color: "blue")
      input = {
        event_date: "2026-07-01",
        start_time: "09:00",
        end_time: "10:00",
        repeat_frequency: "weekly",
        repeat_ends_on: "2026-07-01"
      }
      AssignSchedule.call(event: event, input: input)

      result = CreateRepeatingSeries.call(
        user: user,
        base_event: event,
        event_attributes: { title: "Planning", description: nil, all_day: false, color: "blue" },
        input: input
      )

      assert result
      series = user.event_series.order(:created_at).last
      assert_equal 1, series.occurrences_count
      assert_equal [ Date.new(2026, 7, 1) ], series.events.order(:starts_at).map { |created_event| created_event.starts_at.to_date }
    end

    test "uses anchor event when shortening a series from a later occurrence" do
      user = users(:one)
      series = user.event_series.create!(repeat_frequency: "weekly", repeat_ends_on: Date.new(2026, 8, 26), occurrences_count: 9)
      anchor_event = user.events.create!(title: "Planning", color: "blue", starts_at: Time.zone.local(2026, 7, 1, 9), ends_at: Time.zone.local(2026, 7, 1, 10), event_series: series)
      selected_event = user.events.create!(title: "Planning", color: "blue", starts_at: Time.zone.local(2026, 8, 26, 9), ends_at: Time.zone.local(2026, 8, 26, 10), event_series: series)
      input = {
        repeat_frequency: "weekly",
        repeat_ends_on: "2026-07-15"
      }

      result = CreateRepeatingSeries.call(
        user: user,
        base_event: selected_event,
        event_attributes: { title: "Planning", description: nil, all_day: false, color: "blue" },
        input: input,
        anchor_event: anchor_event
      )

      assert result
      new_series = user.event_series.order(:created_at).last
      assert_equal 3, new_series.occurrences_count
      assert_equal [ Date.new(2026, 7, 1), Date.new(2026, 7, 8), Date.new(2026, 7, 15) ], new_series.events.order(:starts_at).map { |created_event| created_event.starts_at.to_date }
    end

    test "rejects repeat end date in the past" do
      user = users(:one)
      event = user.events.new(title: "Planning", color: "blue")
      input = {
        event_date: "2026-07-01",
        start_time: "09:00",
        end_time: "10:00",
        repeat_frequency: "weekly",
        repeat_ends_on: (Time.zone.today - 1.day).iso8601
      }
      AssignSchedule.call(event: event, input: input)

      result = CreateRepeatingSeries.call(
        user: user,
        base_event: event,
        event_attributes: { title: "Planning", description: nil, all_day: false, color: "blue" },
        input: input
      )

      assert_not result
      assert_includes event.errors[:repeat_ends_on], "cannot be in the past"
    end
  end
end
