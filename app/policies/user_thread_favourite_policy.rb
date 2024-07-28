# frozen_string_literal: true

class UserThreadFavouritePolicy < ApplicationPolicy
  def create?
    user # we pass in current user so no need for auth
  end

  alias destroy? create?
end
