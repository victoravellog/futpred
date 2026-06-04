class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
    @organization = Organization.find_by(invite_token: session[:invite_token]) if session[:invite_token]
  end

  def create
    @user = User.new(user_params)
    if @user.save
      join_organization_from_invite
      start_new_session_for(@user)
      redirect_to root_path, notice: t("auth.account_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :terms_accepted)
  end

  def join_organization_from_invite
    return unless session[:invite_token]
    organization = Organization.find_by(invite_token: session[:invite_token])
    @user.organizations << organization if organization
    session.delete(:invite_token)
  end
end
