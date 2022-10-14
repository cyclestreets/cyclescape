# frozen_string_literal: true

class UserThreadFavouritePolicy < ApplicationPolicy
  def create?
    user.id == record.user_id
  end
  alias destroy? create?
end
