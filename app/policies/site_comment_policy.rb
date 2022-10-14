# frozen_string_literal: true

class SiteCommentPolicy < ApplicationPolicy
  def new?
    user
  end
  alias create? new?

  def index?
    root_or_admin?
  end
  alias destroy? index?
end
