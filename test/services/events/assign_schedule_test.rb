require "test_helper"

module Events
  class AssignScheduleTest < ActiveSupport::TestCase
    test "returns false when date is missing" do
      event = users(:one).events.new(title: "Planning", color: "white")

      result = AssignSchedule.call(event: event, input: { event_date: "", start_time: "09:00", end_time: "10:00" })

      assert_not result
      assert_includes event.errors.attribute_names, :starts_at
    end

    test "returns false when timed event is missing time input" do
      event = users(:one).events.new(title: "Planning", color: "white", all_day: false)

      result = AssignSchedule.call(event: event, input: { event_date: "2026-06-26", start_time: "", end_time: "10:00" })

      assert_not result
      assert_includes event.errors.attribute_names, :starts_at
    end

    test "assigns all day schedule without time input" do
      event = users(:one).events.new(title: "Planning", color: "white", all_day: true)

      result = AssignSchedule.call(event: event, input: { event_date: "2026-06-26", start_time: "", end_time: "" })

      assert result
      assert_equal Time.zone.local(2026, 6, 26).beginning_of_day, event.starts_at
      assert_equal Time.zone.local(2026, 6, 26).end_of_day.to_fs(:db), event.ends_at.to_fs(:db)
    end

    test "treats midnight end time after a late start as next day" do
      event = users(:one).events.new(title: "Planning", color: "white", all_day: false)

      result = AssignSchedule.call(event: event, input: { event_date: "2026-06-26", start_time: "23:00", end_time: "00:00" })

      assert result
      assert event.valid?
      assert_equal Time.zone.local(2026, 6, 26, 23), event.starts_at
      assert_equal Time.zone.local(2026, 6, 27), event.ends_at
    end

    test "treats midnight start as selected day and midnight end as next day" do
      event = users(:one).events.new(title: "Planning", color: "white", all_day: false)

      result = AssignSchedule.call(event: event, input: { event_date: "2026-06-26", start_time: "00:00", end_time: "00:00" })

      assert result
      assert event.valid?
      assert_equal Time.zone.local(2026, 6, 26), event.starts_at
      assert_equal Time.zone.local(2026, 6, 27), event.ends_at
    end
  end
end
