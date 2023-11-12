# frozen_string_literal: true

class SiteCommentPolicy < ApplicationPolicy
  def index?
    root_or_admin?
  end
  alias destroy? index?
end
