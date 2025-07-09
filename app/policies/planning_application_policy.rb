class PlanningApplicationPolicy < ApplicationPolicy
  def index?
    user
  end
end
