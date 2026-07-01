class EventsController < ApplicationController
  include CalendarViewContext
  include UpcomingViewContext

  before_action :require_authentication
  before_action :set_event, only: %i[update destroy]

  def create
    event = current_user.events.new(base_event_params)
    schedule_assigned = Events::AssignSchedule.call(event: event, input: event_input)

    if !schedule_assigned
      render_return_page_with_errors(event)
    elsif repeat_event?
      create_repeated_events(event)
    elsif event.save
      redirect_to event_return_path, notice: "Event created."
    else
      render_return_page_with_errors(event)
    end
  end

  def update
    schedule_assigned = Events::AssignSchedule.call(event: @event, input: event_input)

    if schedule_assigned && update_event
      redirect_to event_return_path, notice: "Event updated."
    else
      render_return_page_with_errors(@event)
    end
  end

  def destroy
    if delete_series?
      @event.event_series.destroy!
      redirect_to event_return_path, notice: "Event series deleted."
    else
      @event.destroy!
      redirect_to event_return_path, notice: "Event deleted."
    end
  end

  private

  # Loads only events owned by the signed-in user before mutating them.
  def set_event
    @event = current_user.events.find(params[:id])
  end

  # Branches create requests between a single event and a generated recurring series.
  def repeat_event?
    event_input[:repeat_event] == "1"
  end

  # Treats deletion of a repeated event as deletion of its whole series.
  def delete_series?
    params[:delete_scope] == "series" && @event.event_series.present?
  end

  # Delegates recurring event generation while keeping the controller responsible for navigation.
  def create_repeated_events(base_event)
    created = Events::CreateRepeatingSeries.call(
      user: current_user,
      base_event: base_event,
      event_attributes: base_event_params,
      input: event_input
    )

    if created
      redirect_to event_return_path, notice: "Repeating event series created."
    else
      render_return_page_with_errors(base_event)
    end
  end

  # Rebuilds the full series when repeat settings are present; otherwise updates one event.
  def update_event
    return update_repeated_event if repeat_event?

    @event.update(base_event_params.merge(starts_at: @event.starts_at, ends_at: @event.ends_at))
  end

  def update_repeated_event
    series = @event.event_series
    anchor_event = series&.events&.chronological&.first || @event

    created = Events::CreateRepeatingSeries.call(
      user: current_user,
      base_event: @event,
      event_attributes: base_event_params,
      input: event_input,
      anchor_event: anchor_event
    )

    series&.destroy! if created
    created
  end

  # Rebuilds the page that submitted the form so validation errors appear in context.
  def render_return_page_with_errors(event)
    @event_with_errors = event
    @open_event_modal = event.new_record?
    @new_event = event.new_record? ? event : current_user.events.new(default_event_values)
    build_return_view_data

    render return_template, status: :unprocessable_entity
  end

  # Builds either calendar or upcoming data before rendering a failed form submission.
  def build_return_view_data
    return build_upcoming_data if upcoming_return?

    build_calendar_data
  end

  # Selects the full-page template matching the page that submitted the event form.
  def return_template
    upcoming_return? ? "upcoming/show" : "calendar/show"
  end

  # Redirects back to upcoming when agenda range params were submitted, otherwise calendar.
  def event_return_path
    return upcoming_path(upcoming_location_params) if upcoming_return?

    calendar_path(calendar_location_params)
  end

  # Detects event forms submitted from the upcoming agenda instead of the calendar page.
  def upcoming_return?
    params[:date].present? || params[:days].present?
  end

  # Core persisted attributes; schedule fields are parsed by Events::AssignSchedule.
  def base_event_params
    event_params.slice(:title, :description, :all_day, :color).merge(color: selected_color)
  end

  # Ensures the UI cannot submit arbitrary color class names.
  def selected_color
    color = event_params[:color].presence
    return color if Event::COLORS.include?(color)

    "white"
  end

  # Raw event form input, including virtual fields used by event services.
  def event_input
    params.fetch(:event, {})
  end

  # Whitelists event form fields, including virtual date/time inputs.
  def event_params
    params.require(:event).permit(:title, :description, :all_day, :color, :event_date, :start_time, :end_time, :repeat_event, :repeat_frequency, :repeat_ends_on)
  end

  # Preserves calendar position after redirects and validation errors.
  def calendar_location_params
    params.permit(:view, :month, :week).to_h.compact_blank
  end

  # Preserves upcoming agenda position after redirects and validation errors.
  def upcoming_location_params
    params.permit(:date, :days).to_h.compact_blank
  end
end
