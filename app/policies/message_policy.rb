# frozen_string_literal: true

class MessagePolicy < ApplicationPolicy
  def show?
    Pundit.policy!(user, record.thread).show?
  end
  alias create? show?
end
