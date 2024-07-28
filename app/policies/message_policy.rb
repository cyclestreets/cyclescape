# frozen_string_literal: true

class MessagePolicy < GuestsAllowedPolicy
  def show?
    Pundit.policy!(user, record.thread).show?
  end

  def censor?
    user && in_group_committee?
  end
  alias approve? censor?
  alias reject? censor?

  # if you can view a thread then you can add to it
  alias create? show?
  alias vote_up? show?
  alias vote_clear? show?

  private

  def group
    @group ||= record.thread&.group
  end
end
