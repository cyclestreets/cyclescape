# frozen_string_literal: true

class IssuePolicy < ApplicationPolicy
  def new?
    user
  end

  alias edit? created_by_current_user_or_admin
  alias update? created_by_current_user_or_admin
  alias create? created_by_current_user_or_admin
  alias destroy? admin?
end
