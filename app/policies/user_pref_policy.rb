# frozen_string_literal: true

class UserPrefPolicy < ApplicationPolicy
  def edit?
    root_or_admin? || (user.id == record.user_id)
  end

  alias destroy? create?
end
