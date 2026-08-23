class InvitesController < ApplicationController
  allow_unauthenticated_access only: [ :show ]

  def show
    @organization = Organization.find_by!(invite_token: params[:token])
    authenticated?

    if Current.user
      if Current.user.organizations.include?(@organization)
        redirect_to organization_path(@organization), notice: t("invites.already_member")
      end
    else
      session[:invite_token] = params[:token]
      redirect_to new_registration_path, notice: t("invites.register_first")
    end
  end

  def accept
    @organization = Organization.find_by!(invite_token: params[:token])

    if Current.user.organizations.include?(@organization)
      redirect_to organization_path(@organization), notice: t("invites.already_member")
    else
      Current.user.organizations << @organization
      CopyPredictionsToOrganization.call(user: Current.user, organization: @organization)
      redirect_to organization_path(@organization), notice: t("invites.joined")
    end
  end
end
