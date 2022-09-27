# frozen_string_literal: true

class GroupMembershipRequestPolicy < ApplicationPolicy
  alias index? in_group_committee?
  alias review? in_group_committee?
  alias confirm? in_group_committee?
  alias reject? in_group_committee?

  def new?
    !(user.groups + user.requested_groups).include?(group)
  end

  alias create? new?

  def cancel?
    user.id == record.user_id
  end

  delegate :group, to: :record
end
