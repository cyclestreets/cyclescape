# frozen_string_literal: true

class IssuePolicy < GuestsAllowedPolicy
  def new?
    user
  end

  def create?
    user.approved?
  end

  alias update_tags? new?
  alias edit? created_by_current_user_or_admin?
  alias update? created_by_current_user_or_admin?
  alias destroy? admin?
end
