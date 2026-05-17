class Api::V1::GameRolesController < ApplicationController
  include JwtHelper

  before_action :require_auth, only: [:select]

  def index
    roles = User.game_roles.keys.map do |key|
      {
        key: key,
        label: I18n.t("game_roles.#{key}.label"),
        subtitle: I18n.t("game_roles.#{key}.subtitle"),
        description: I18n.t("game_roles.#{key}.description"),
        specialty_category: User::GAME_ROLE_SPECIALTIES[key],
        perks: Array(I18n.t("game_roles.#{key}.perks", default: []))
      }
    end

    render_success(data: { game_roles: roles })
  end

  def select
    new_role = params[:game_role].to_s

    unless User.game_roles.key?(new_role)
      return render_validation_error(message: I18n.t('pages.select_game_role.invalid_role'))
    end

    current_user.assign_game_role!(new_role)

    render_success(
      data: {
        user: {
          id: current_user.id,
          email: current_user.email,
          game_role: current_user.game_role,
          game_role_selected_at: current_user.game_role_selected_at
        }
      },
      message: I18n.t('pages.select_game_role.assigned', role: current_user.game_role_label)
    )
  end
end
