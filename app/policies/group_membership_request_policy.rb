# frozen_string_literal: true

class GroupMembershipRequestPolicy < ApplicationPolicy
  alias index? in_group_committee?
  alias review? in_group_committee?
  alias confirm? in_group_committee?
  alias reject? in_group_committee?

  def new?
    true
  end

  alias create? new?

  def cancel?
    user.id == record.user_id
  end

  delegate :group, to: :record
end
