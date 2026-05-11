class DashboardController < ApplicationController
  def show
    @organizations = Current.user.organizations
  end
end
