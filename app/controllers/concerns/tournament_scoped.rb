module TournamentScoped
  extend ActiveSupport::Concern

  private

  def set_tournament_context
    @organization = find_user_organization_for_tournament
    @organization_tournament = OrganizationTournament.find_by!(
      organization: @organization,
      tournament: @tournament
    )
    @user_in_multiple_groups = user_tournament_groups_count > 1
  end

  def find_user_organization_for_tournament
    user_orgs = Current.user.organizations
                            .joins(:organization_tournaments)
                            .where(organization_tournaments: { tournament_id: @tournament.id })

    if params[:organization_id].present?
      user_orgs.find(params[:organization_id])
    else
      user_orgs.first!
    end
  end

  def user_tournament_groups_count
    Current.user.organizations
           .joins(:organization_tournaments)
           .where(organization_tournaments: { tournament_id: @tournament.id })
           .count
  end
end
