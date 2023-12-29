# frozen_string_literal: true

class MessageThreadPolicy < ApplicationPolicy
  def initialize(user, thread)
    @user = user
    @thread = thread
  end

  def new?
    return false unless user
    return true if root_or_admin?

    if thread.has_issue?
      true
    elsif thread.group_id
      if thread.private_to_committee?
        thread.group_committee_members.include?(user)
      else
        user.group_ids.include?(thread.group_id)
      end
    elsif thread.user
      view_full_name?(thread.user) && user.id != thread.user_id &&
        !UserBlock.where(user: user, blocked: thread.user).or(UserBlock.where(user: thread.user, blocked: user)).exists?
    end
  end

  alias create? new?

  def show?
    return true if thread.public? || root_or_admin?
    return false unless user

    if thread.private_to_committee?
      thread.group_committee_members.include?(user)
    elsif thread.private_message?
      thread.user == user || thread.created_by == user
    elsif thread.private_to_group?
      user.group_ids.include?(thread.group_id)
    end
  end

  alias update_tags? show?

  def edit?
    return true if root_or_admin?

    if user && thread.created_by == user && thread.created_at > 24.hours.ago
      return true
    end

    in_group_committee? && show?
  end

  alias update? edit?

  def destroy?
    in_group_committee? && show?
  end

  def edit_all_fields?
    in_group_committee?
  end

  def open?
    thread.closed && subscribed_or_admin?
  end

  def close?
    !thread.closed && subscribed_or_admin?
  end

  def vote_detail?
    user && show?
  end

  private

  def subscribed_or_admin?
    user && (thread.subscribers.include?(user) || root_or_admin?)
  end

  attr_reader :thread
  delegate :group, to: :thread, allow_nil: true
end
