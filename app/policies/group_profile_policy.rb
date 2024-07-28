# frozen_string_literal: true

class GroupProfilePolicy < ApplicationPolicy
  alias edit? in_group_committee?
  alias update? in_group_committee?

  delegate :group, to: :record
end
