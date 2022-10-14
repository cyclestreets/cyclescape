# frozen_string_literal: true

class ThreadSubscriptionPolicy < ApplicationPolicy
  def edit?
    user.id == record.user_id
  end

  def create?
    MessageThreadPolicy.new(user, record.thread).show?
  end
  alias destroy? create?
end
