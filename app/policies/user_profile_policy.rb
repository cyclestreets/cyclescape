# frozen_string_literal: true

class UserProfilePolicy < ApplicationPolicy
  def show?
    view_full_name?(record.user)
  end

  alias edit? created_by_current_user_or_admin?
  alias create? created_by_current_user_or_admin?
  alias update? created_by_current_user_or_admin?
end
