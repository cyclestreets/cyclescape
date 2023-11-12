# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end

  def root_or_admin?
    root? || admin?
  end

  def created_by_current_user_or_admin?
    root_or_admin? || (user && user.id == record.created_by_id)
  end

  def in_group_committee?
    root_or_admin? || (user && group && group.committee_members.where(id: user.id).exists?)
  end

  def view_full_name?(other_user)
    return true if root_or_admin? || other_user.profile.visibility == "public"
    return false unless user

    user.id == other_user.id || (user.group_ids & other_user.group_ids).present? ||
      (user.in_group_committee.ids & other_user.requested_groups.ids).present?
  end

  delegate :root?, :admin?, to: :@user, allow_nil: true
end
