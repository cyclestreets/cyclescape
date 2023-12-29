# frozen_string_literal: true

class MessagePolicy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    Pundit.policy!(user, record.thread).show?
  end

  def censor?
    user && in_group_committee?
  end

  # if you can view a thread then you can add to it
  alias create? show?

  private

  def group
    @group ||= record.thread&.group
  end
end
