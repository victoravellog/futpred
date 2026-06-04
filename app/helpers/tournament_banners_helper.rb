module TournamentBannersHelper
  def upcoming_tournaments_for_user(user)
    return [] unless user

    Tournament.joins(organizations: :memberships)
              .where(memberships: { user_id: user.id })
              .distinct
              .select { |t| t.starts_at.present? && t.days_until_start&.between?(0, 30) }
              .sort_by(&:starts_at)
  end

  def tournament_urgency_class(days_until)
    case days_until
    when 0..1 then "banner-urgent"
    when 2..7 then "banner-warning"
    else "banner-info"
    end
  end

  def tournament_countdown_text(tournament)
    days = tournament.days_until_start
    return nil unless days

    case days
    when 0 then t("banners.tournament.starts_today")
    when 1 then t("banners.tournament.starts_tomorrow")
    when 2..7 then t("banners.tournament.starts_in_days", count: days)
    else t("banners.tournament.starts_in_weeks", count: (days / 7.0).ceil)
    end
  end
end
