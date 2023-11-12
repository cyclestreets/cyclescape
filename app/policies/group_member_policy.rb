# frozen_string_literal: true

class GroupMemberPolicy < ApplicationPolicy
  alias index? in_group_committee?
end
