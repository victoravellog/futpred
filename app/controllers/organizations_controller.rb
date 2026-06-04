class OrganizationsController < ApplicationController
  before_action :set_organization, only: [ :show, :edit, :update ]
  before_action :require_owner, only: [ :edit, :update ]

  def new
    @organization = Organization.new
  end

  def show
    @tournaments = @organization.tournaments.order(created_at: :desc)
    @membership = @organization.memberships.find_by(user: Current.user)
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      Current.user.memberships.create!(organization: @organization, role: :owner)
      redirect_to root_path, notice: t("organizations.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: t("organizations.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Current.user.organizations.find(params[:id])
  end

  def require_owner
    membership = @organization.memberships.find_by(user: Current.user)
    redirect_to @organization, alert: t("organizations.not_authorized") unless membership&.owner?
  end

  def organization_params
    params.require(:organization).permit(:name, :locale)
  end
end
