# frozen_string_literal: true

module Library
  class NotePolicy < ApplicationPolicy
    alias update? created_by_current_user_or_admin?
  end
end
