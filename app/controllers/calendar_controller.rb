class CalendarController < ApplicationController
  before_action :require_authentication

  def show
    build_calendar_data
    @new_event ||= current_user.events.new(default_event_values)
  end

  def upcoming; end

  def settings; end

  private

  def build_calendar_data
    today = Time.zone.today
    @calendar_view = params[:view] == "week" ? "week" : "month"
    current_month_start = today.beginning_of_month
    current_week_start = today.beginning_of_week(:monday)
    calendar_start = current_month_start.beginning_of_week(:monday)
    calendar_end = current_month_start.end_of_month.end_of_week(:monday)

    @current_month_start = current_month_start
    @current_week_start = current_week_start
    @calendar_days = (calendar_start..calendar_end).to_a
    @week_days = (current_week_start..current_week_start.end_of_week(:monday)).to_a

    event_start = @calendar_view == "week" ? current_week_start : calendar_start
    event_end = @calendar_view == "week" ? current_week_start.end_of_week(:monday) : calendar_end
    @events_by_date = current_user.events.where(starts_at: event_start.beginning_of_day..event_end.end_of_day).chronological.group_by { |event| event.starts_at.to_date }
  end

  def default_event_values
    now = Time.zone.now.change(min: 0)
    {
      starts_at: now,
      ends_at: now + 1.hour,
      color: "white",
      event_date: now.to_date.iso8601,
      start_time: now.strftime("%H:%M"),
      end_time: (now + 1.hour).strftime("%H:%M"),
      repeat_frequency: "weekly"
    }
  end
end
