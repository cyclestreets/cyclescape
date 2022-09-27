# frozen_string_literal: true

class UserThreadFavouritePolicy < ApplicationPolicy
  def create?
    user && user.id == record.user_id
  end
end
