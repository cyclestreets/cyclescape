# frozen_string_literal: true

class ApplicationPolicy
  class Pundit::NoUserError < Pundit::NotAuthorizedError; end

  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NoUserError, "must be logged in" unless user

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

  def created_by_id
    record.created_by_id
  end

  def created_by_current_user_or_admin?
    root_or_admin? || (user && user.id == created_by_id)
  end

  def in_group_committee?
    root_or_admin? || (user && group && group.committee_members.where(id: user.id).exists?)
  end

  def application_view_profile?(user_being_viewed)
    user_being_viewed.profile.visibility == "public" || application_view_full_name?(user_being_viewed)
  end

  def application_view_full_name?(user_being_viewed)
    return true if root_or_admin?
    return false unless user

    user.id == user_being_viewed.id || (user.group_ids & user_being_viewed.group_ids).present? ||
      (user.in_group_committee.ids & user_being_viewed.requested_groups.ids).present?
  end

  delegate :root?, :admin?, to: :@user, allow_nil: true
end
