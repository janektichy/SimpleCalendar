class CalendarController < ApplicationController
  before_action :require_authentication

  # Placeholder calendar dashboard content until event features land
  def show; end

  def upcoming; end

  def settings; end
end
