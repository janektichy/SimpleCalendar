class UpcomingController < ApplicationController
  include UpcomingViewContext

  before_action :require_authentication

  def show
    build_upcoming_data
    @new_event ||= current_user.events.new(default_event_values)
  end
end
