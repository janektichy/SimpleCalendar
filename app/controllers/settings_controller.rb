class SettingsController < ApplicationController
  before_action :require_authentication

  def show
    @settings_section = selected_settings_section
  end

  def update_profile
    @settings_section = "account"

    if current_user.update(profile_params)
      redirect_to settings_path(section: @settings_section), notice: "Profile settings updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def update_password
    @settings_section = "account"

    unless current_user.authenticate(password_params[:current_password])
      current_user.errors.add(:current_password, "is incorrect")
      return render :show, status: :unprocessable_entity
    end

    if current_user.update(password_params.except(:current_password))
      redirect_to settings_path(section: @settings_section), notice: "Password updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def update_input_configuration
    @settings_section = "general"

    if current_user.update(input_configuration_params)
      redirect_to settings_path(section: @settings_section), notice: "Input configuration updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  # Keeps failed submissions on the settings tab where the form lives.
  def selected_settings_section
    return params[:section] if %w[account general].include?(params[:section])

    "account"
  end

  # Allows changing the email address used for sign-in and reminders.
  def profile_params
    params.require(:user).permit(:email)
  end

  # Allows password changes only after the current password check passes.
  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  # Stores account-level defaults used by calendar and upcoming pages.
  def input_configuration_params
    params.require(:user).permit(:default_upcoming_days, :default_calendar_view)
  end
end
