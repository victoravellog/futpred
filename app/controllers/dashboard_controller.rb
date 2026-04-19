class DashboardController < ApplicationController
  def show
    orgs = Current.user.organizations
    redirect_to organization_path(orgs.first) if orgs.count == 1
  end
end
