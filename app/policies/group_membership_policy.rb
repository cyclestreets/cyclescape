# frozen_string_literal: true

class GroupMembershipPolicy < ApplicationPolicy
  alias new? in_group_committee?
  alias create? in_group_committee?
  alias edit? in_group_committee?
  alias update? in_group_committee?
  alias destroy? in_group_committee?

  delegate :group, to: :record
end
