class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :user_signed_in?

  private

  # Exposes the currently authenticated user object for controllers and views
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  # Redirects visitors attempting to access secure sections without authenticating
  def require_authentication
    return if user_signed_in?

    redirect_to new_session_path, alert: "Please sign in to continue."
  end

  # Keeps signed-in users from seeing auth pages again
  def redirect_authenticated_user
    redirect_to calendar_path if user_signed_in?
  end
end
