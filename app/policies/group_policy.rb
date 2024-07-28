# frozen_string_literal: true

class GroupPolicy < GuestsAllowedPolicy
  alias view_active_users? in_group_committee?

  alias group record
end
