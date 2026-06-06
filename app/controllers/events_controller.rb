class EventsController < ApplicationController
  REPEAT_OCCURRENCES_COUNT = 24

  before_action :require_authentication
  before_action :set_event, only: %i[update destroy]

  def create
    event = current_user.events.new(base_event_params)
    assign_form_state(event)
    assign_schedule(event)

    if repeat_event?
      create_repeated_events(event)
    elsif event.save
      redirect_with_callback("Event created.")
    else
      render_calendar_with_errors(event)
    end
  end

  def destroy
    if delete_series?
      @event.event_series.destroy!
      redirect_with_callback("Event series deleted.")
    else
      @event.destroy!
      redirect_with_callback("Event deleted.")
    end
  end

  def update
    assign_form_state(@event)
    assign_schedule(@event)

    if @event.errors.none? && @event.update(base_event_params.merge(starts_at: @event.starts_at, ends_at: @event.ends_at))
      redirect_with_callback("Event updated.")
    else
      render_calendar_with_errors(@event)
    end
  end

  private

  def set_event
    @event = current_user.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :all_day, :color, :event_date, :start_time, :end_time)
  end

  def base_event_params
    event_params.slice(:title, :description, :all_day, :color).merge(color: selected_color)
  end

  def assign_form_state(event)
    event.repeat_event = event_input[:repeat_event]
    event.repeat_frequency = event_input[:repeat_frequency]
    event.event_date = event_input[:event_date]
    event.start_time = event_input[:start_time]
    event.end_time = event_input[:end_time]
  end

  def assign_schedule(event)
    event_date = parse_event_date

    unless event_date
      event.errors.add(:starts_at, "date is required")
      return
    end

    if event.all_day?
      event.starts_at = event_date.beginning_of_day
      event.ends_at = event_date.end_of_day
      return
    end

    starts_at = parse_event_time(event_date, event_input[:start_time])
    ends_at = parse_event_time(event_date, event_input[:end_time])

    event.starts_at = starts_at
    event.ends_at = ends_at
    event.errors.add(:starts_at, "time is required") if starts_at.blank?
    event.errors.add(:ends_at, "time is required") if ends_at.blank?
  end

  def parse_event_date
    value = event_input[:event_date].to_s
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

  def repeat_event?
    event_input[:repeat_event] == "1"
  end

  def delete_series?
    params[:delete_scope] == "series" && @event.event_series.present?
  end

  def create_repeated_events(base_event)
    series = current_user.event_series.new(series_params)

    unless base_event.valid? && series.valid?
      merge_errors(base_event, series)
      return render_calendar_with_errors(base_event)
    end

    ActiveRecord::Base.transaction do
      series.save!
      build_repeated_events(base_event, series).each(&:save!)
    end

    redirect_with_callback("Repeating event series created.")
  rescue ActiveRecord::RecordInvalid
    merge_errors(base_event, series)
    render_calendar_with_errors(base_event)
  end

  def series_params
    {
      repeat_frequency: normalized_repeat_frequency,
      occurrences_count: REPEAT_OCCURRENCES_COUNT
    }
  end

  def normalized_repeat_frequency
    frequency = event_input[:repeat_frequency].to_s
    return frequency if EventSeries.repeat_frequencies.key?(frequency)

    "weekly"
  end

  def selected_color
    color = event_params[:color].presence
    return color if Event::COLORS.include?(color)

    "white"
  end

  def event_input
    params.fetch(:event, {})
  end

  def build_repeated_events(base_event, series)
    (1..series.occurrences_count).map do |step|
      starts_at = shifted_time(base_event.starts_at, series.repeat_frequency, step - 1)
      ends_at = shifted_time(base_event.ends_at, series.repeat_frequency, step - 1)

      current_user.events.new(
        base_event_params.merge(
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

  def render_calendar_with_errors(event)
    @event_with_errors = event
    @open_event_modal = event.new_record?
    @new_event = event.new_record? ? event : current_user.events.new(default_event_values)
    build_calendar_data

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("callback_messages", partial: "shared/callback_messages", locals: { errors: [event] }),
          turbo_stream.replace("calendar_page", partial: "calendar/page")
        ], status: :unprocessable_entity
      end
      format.html { render "calendar/show", status: :unprocessable_entity }
    end
  end

  def redirect_with_callback(message)
    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = message
        build_calendar_data
        @new_event = current_user.events.new(default_event_values)

        render turbo_stream: [
          turbo_stream.update("callback_messages", partial: "shared/callback_messages"),
          turbo_stream.replace("calendar_page", partial: "calendar/page")
        ]
      end
      format.html { redirect_to calendar_path, notice: message }
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

  def build_calendar_data
    today = Time.zone.today
    current_month_start = today.beginning_of_month
    calendar_start = current_month_start.beginning_of_week(:monday)
    calendar_end = current_month_start.end_of_month.end_of_week(:monday)

    @current_month_start = current_month_start
    @calendar_days = (calendar_start..calendar_end).to_a
    @events_by_date = current_user.events.where(starts_at: calendar_start.beginning_of_day..calendar_end.end_of_day).chronological.group_by { |item| item.starts_at.to_date }
  end
end
