class SessionsController < ApplicationController
  layout "auth"
  before_action :redirect_authenticated_user, only: %i[new create]

  # Renders the login form with a lightweight user object for error messaging
  def new
    @user = User.new
  end

  def create
    email = session_params[:email].to_s
    @user = User.new(email: email)
    user = User.find_by(email: email.downcase)

    if user&.authenticate(session_params[:password])
      session[:user_id] = user.id
      redirect_to calendar_path, notice: "Welcome back."
    else
      @user.errors.add(:base, "Invalid email or password")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to new_session_path, notice: "Signed out successfully."
  end

  private

  def session_params
    params.require(:user).permit(:email, :password)
  end
end
