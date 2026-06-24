module CalendarViewContext
  extend ActiveSupport::Concern

  private

  def build_calendar_data
    today = Time.zone.today
    @calendar_view = selected_calendar_view
    current_month_start = selected_month_start(today)
    current_week_start = selected_week_start(today)
    calendar_start = current_month_start.beginning_of_week(:monday)
    calendar_end = current_month_start.end_of_month.end_of_week(:monday)

    @current_month_start = current_month_start
    @current_week_start = current_week_start
    @today = today
    @calendar_days = (calendar_start..calendar_end).to_a
    @week_days = (current_week_start..current_week_start.end_of_week(:monday)).to_a

    event_start = @calendar_view == "week" ? current_week_start : calendar_start
    event_end = @calendar_view == "week" ? current_week_start.end_of_week(:monday) : calendar_end
    @events_by_date = current_user.events.where(starts_at: event_start.beginning_of_day..event_end.end_of_day).chronological.group_by { |event| event.starts_at.to_date }
  end

  def selected_calendar_view
    return params[:view] if %w[month week].include?(params[:view])

    current_user.default_calendar_view
  end

  def selected_month_start(today)
    Date.strptime(params[:month].to_s, "%Y-%m").beginning_of_month
  rescue Date::Error
    today.beginning_of_month
  end

  def selected_week_start(today)
    parsed_week = begin
      Date.iso8601(params[:week].to_s)
    rescue Date::Error
      nil
    end

    return parsed_week.beginning_of_week(:monday) if parsed_week

    month_start = selected_month_start(today)
    if month_start == today.beginning_of_month
      today.beginning_of_week(:monday)
    else
      month_start.beginning_of_week(:monday)
    end
  end
end
