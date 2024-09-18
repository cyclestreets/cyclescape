# frozen_string_literal: true

class GroupRequestPolicy < ApplicationPolicy
  def index?
    root_or_admin?
  end

  alias review? index?
  alias confirm? index?
  alias reject? index?
  alias destroy? index?

  def new?
    user
  end
  alias create? new?

  def cancel?
    created_by_current_user_or_admin?
  end
end
