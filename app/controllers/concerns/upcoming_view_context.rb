module UpcomingViewContext
  extend ActiveSupport::Concern

  private

  def build_upcoming_data
    today = Time.zone.today
    @selected_date = selected_upcoming_date(today)
    @upcoming_days_count = selected_upcoming_days_count
    @upcoming_days = (@selected_date...(@selected_date + @upcoming_days_count.days)).to_a
    @upcoming_month_start = @selected_date.beginning_of_month
    @upcoming_calendar_days = (@upcoming_month_start.beginning_of_week(:monday)..@upcoming_month_start.end_of_month.end_of_week(:monday)).to_a
    @today = today
    @events_by_date = upcoming_events_for_range(@selected_date, @upcoming_days.last).group_by { |event| event.starts_at.to_date }
  end

  def upcoming_events_for_range(event_start, event_end)
    range_start = event_start.beginning_of_day
    range_end = event_end.end_of_day
    events = current_user.events.includes(:event_series).where("starts_at <= ? AND (event_series_id IS NOT NULL OR ends_at >= ?)", range_end, range_start).chronological

    Events::ExpandRepeatingEvents.call(events: events, range_start: range_start, range_end: range_end)
  end

  def selected_upcoming_date(today)
    Date.iso8601(params[:date].to_s)
  rescue Date::Error
    today
  end

  def selected_upcoming_days_count
    selected_days = params[:days].presence || current_user.default_upcoming_days
    selected_days.to_i.clamp(1, 14)
  end
end
