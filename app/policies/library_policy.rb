# frozen_string_literal: true

class LibraryPolicy < ApplicationPolicy
  def new?
    user
  end
end
