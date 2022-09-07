# frozen_string_literal: true

class UserThreadFavouritePolicy
  def create?
    current_user && current_user.id == record.user_id
  end
end
