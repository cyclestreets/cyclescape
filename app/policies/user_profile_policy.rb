# frozen_string_literal: true

class UserProfilePolicy < ApplicationPolicy
  def show?
    view_full_name?(record.user)
  end

  alias destroy? create?
end
