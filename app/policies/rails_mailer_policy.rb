# frozen_string_literal: true

class RailsMailerPolicy < ApplicationPolicy
  def index?
    root_or_admin?
  end
end
