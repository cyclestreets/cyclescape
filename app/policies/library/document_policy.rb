# frozen_string_literal: true

module Library
  class DocumentPolicy < ApplicationPolicy
    def initialize(user, record)
      @user = user
      @record = record
    end

    def new?
      user
    end
    alias create? new?

    alias edit? created_by_current_user_or_admin?
    alias update? created_by_current_user_or_admin?
    alias destroy? created_by_current_user_or_admin?
  end
end
