class RegistrationsController < ApplicationController
  layout "auth"
  before_action :redirect_authenticated_user, only: %i[new create]

  # Presents the sign-up form that seeds the first authenticated session
  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to calendar_path, notice: "Account created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
