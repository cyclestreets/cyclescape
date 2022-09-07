# frozen_string_literal: true

class AdminPolicy
  def initialize(user, _record)
    @user = user
  end

  def all?
    root? || admin?
  end
end
