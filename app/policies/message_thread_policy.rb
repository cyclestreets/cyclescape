# frozen_string_literal: true

class MessageThreadPolicy < GuestsAllowedPolicy
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
      application_view_full_name?(thread.user) &&
        user.id != thread.user_id && # can't send messages to yourself
        !UserBlock.where(user: user, blocked: thread.user).or(UserBlock.where(user: thread.user, blocked: user)).exists?
    end
  end

  alias create? new?

  def auto_subscribe?
    return true if thread.public?
    return false unless user

    if thread.private_to_committee?
      thread.group_committee_members.include?(user)
    elsif thread.private_message?
      thread.user == user || thread.created_by == user
    elsif thread.private_to_group?
      user.group_ids.include?(thread.group_id)
    end
  end

  def show?
    return true if root_or_admin?

    auto_subscribe?
  end

  def update_tags?
    !!user && show?
  end

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
    thread.new_record? || in_group_committee?
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

  def thread
    @record
  end
  delegate :group, to: :thread, allow_nil: true
end
