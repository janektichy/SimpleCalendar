class CalendarController < ApplicationController
  before_action :require_authentication

  def show
    build_calendar_data
    @new_event ||= current_user.events.new(default_event_values)
  end

  def upcoming
    build_upcoming_data
    @new_event ||= current_user.events.new(default_event_values)
  end

  def settings
    @settings_section = selected_settings_section
  end

  def update_profile
    @settings_section = "account"

    if current_user.update(profile_params)
      redirect_to settings_path(section: @settings_section), notice: "Profile settings updated."
    else
      render :settings, status: :unprocessable_entity
    end
  end

  def update_password
    @settings_section = "account"

    unless current_user.authenticate(password_params[:current_password])
      current_user.errors.add(:current_password, "is incorrect")
      return render :settings, status: :unprocessable_entity
    end

    if current_user.update(password_params.except(:current_password))
      redirect_to settings_path(section: @settings_section), notice: "Password updated."
    else
      render :settings, status: :unprocessable_entity
    end
  end

  def update_input_configuration
    @settings_section = "general"

    if current_user.update(input_configuration_params)
      redirect_to settings_path(section: @settings_section), notice: "Input configuration updated."
    else
      render :settings, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:email)
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def input_configuration_params
    params.require(:user).permit(:default_upcoming_days, :default_calendar_view)
  end

  def selected_settings_section
    return params[:section] if %w[account general].include?(params[:section])

    "account"
  end

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

  def build_upcoming_data
    today = Time.zone.today
    @selected_date = selected_upcoming_date(today)
    @upcoming_days_count = selected_upcoming_days_count
    @upcoming_days = (@selected_date...(@selected_date + @upcoming_days_count.days)).to_a
    @upcoming_month_start = @selected_date.beginning_of_month
    @upcoming_calendar_days = (@upcoming_month_start.beginning_of_week(:monday)..@upcoming_month_start.end_of_month.end_of_week(:monday)).to_a
    @today = today
    @events_by_date = current_user.events.where(starts_at: @selected_date.beginning_of_day..@upcoming_days.last.end_of_day).chronological.group_by { |event| event.starts_at.to_date }
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
