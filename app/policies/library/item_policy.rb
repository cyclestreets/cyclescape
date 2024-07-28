# frozen_string_literal: true

module Library
  class ItemPolicy < ApplicationPolicy
    def initialize(user, record)
      @user = user
      @record = record
    end

    def update_tags?
      user
    end

    alias update? created_by_current_user_or_admin?
  end
end
