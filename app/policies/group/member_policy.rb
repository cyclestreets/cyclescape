# frozen_string_literal: true

class Group
  class MemberPolicy < ApplicationPolicy
    def index?
      in_group_committee?
    end
  end
end
