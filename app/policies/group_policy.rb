# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def index?
    in_group_committee?
  end

  alias view_active_users? index?

  alias group record
end
