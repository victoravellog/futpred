class ProfilesController < ApplicationController
  def show
    @user = Current.user
  end

  def update
    @user = Current.user

    if params[:remove_avatar] == "1"
      @user.avatar.purge
      @user.update(avatar_preset: nil)
      redirect_to profile_path, notice: t("profile.avatar_removed")
    else
      update_params = profile_params.to_h

      # Si se sube un avatar, procesarlo y limpiar el preset
      if update_params[:avatar].present?
        result = ProcessAvatar.call(file: update_params[:avatar])
        update_params[:avatar] = result.processed_file
        update_params[:avatar_preset] = nil
      # Si se selecciona un preset, eliminar el avatar subido
      elsif update_params[:avatar_preset].present?
        @user.avatar.purge if @user.avatar.attached?
      end

      if @user.update(update_params)
        redirect_to profile_path, notice: t("profile.updated")
      else
        render :show, status: :unprocessable_entity
      end
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :avatar, :avatar_preset)
  end
end
