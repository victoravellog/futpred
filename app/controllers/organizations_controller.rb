class OrganizationsController < ApplicationController
  def new
    @organization = Organization.new
  end

  def show
    @organization = Current.user.organizations.find(params[:id])
    @tournaments = @organization.tournaments.order(created_at: :desc)
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      Current.user.memberships.create!(organization: @organization, role: :owner)
      redirect_to root_path, notice: "Organización creada exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name)
  end
end
