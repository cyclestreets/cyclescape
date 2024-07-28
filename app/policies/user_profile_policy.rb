# frozen_string_literal: true

class UserProfilePolicy < GuestsAllowedPolicy
  def show?
    application_view_profile?(record.user)
  end

  alias edit? created_by_current_user_or_admin?
  alias create? created_by_current_user_or_admin?
  alias update? created_by_current_user_or_admin?

  private

  def created_by_id
    record.user_id
  end
end
