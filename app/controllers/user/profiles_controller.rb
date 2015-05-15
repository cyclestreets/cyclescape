class User::ProfilesController < ApplicationController
  before_filter :load_user
  filter_access_to :edit, :create, :update, attribute_check: true, model: User
  filter_access_to :all

  def show
    raise ActionController::RoutingError.new('Not Found') unless permitted_to? :view_profile, @user

    @user = UserDecorator.decorate(@user)

    involved_threads = ThreadList.public_recent_involved_with(@user, 10).includes(:group)
    @involved_threads = ThreadListDecorator.decorate(involved_threads)

    reported_issues = Issue.by_most_recent.created_by(@user)
    @reported_issues = IssueDecorator.decorate(reported_issues)

    # Groups that the current user could invite this particular user to
    @add_to_groups = current_user ? (current_user.memberships.committee.collect { |m| m.group } - @user.groups) : nil
  end

  def edit
    @user = UserDecorator.decorate(@user)
    @profile = @user.profile
  end

  def create
    update
  end

  def update
    if @user.profile.update_attributes(params[:user_profile])
      set_flash_message(:success)
      redirect_to action: :show
    else
      render :edit
    end
  end

  protected

  def load_user
    @user = User.find(params[:user_id])
  end
end
