class Group::MembershipRequestsController < ApplicationController
  before_filter :load_group
  filter_access_to :cancel, attribute_check: true, model: GroupMembershipRequest
  filter_access_to :all, attribute_check: true, model: Group

  def index
    set_page_title t("group.membership_requests.index.title", group: @group.name)

    @requests = @group.membership_requests.order("created_at desc").includes(:user)
  end

  def new
    set_page_title t("group.membership_requests.new.title", group_name: @group.name)

    @request = @group.membership_requests.build
  end

  def create
    if current_user.groups.include?(@group)
      redirect_to @group, alert: t(".group.membership_requests.create.already_member")
    elsif current_user.membership_request_pending_for?(@group)
      redirect_to @group, alert: t(".group.membership_requests.create.already_asked")
    else
      @request = @group.membership_requests.new(params[:group_membership_request])
      @request.user = current_user

      if @request.save
        redirect_to @group, notice: t(".group.membership_requests.create.requested")
        Notifications.new_group_membership_request(@request).deliver
      else
        render :new
      end
    end
  end

  # Review an individual membership request - useful for including in notifications
  # for large groups with many pending membership requests.
  def review
    @request = @group.membership_requests.find(params[:id])
  end

  def confirm
    @request = @group.membership_requests.find(params[:id])
    @request.actioned_by = current_user
    if @request.confirm
      Notifications.group_membership_request_confirmed(@request).deliver
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to action: :index
  end

  def reject
    @request = @group.membership_requests.find(params[:id])
    @request.actioned_by = current_user
    if @request.reject
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to action: :index
  end

  def cancel
    @request = @group.membership_requests.find(params[:id])
    if @request.user == current_user && @request.cancel
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to @group
  end

  protected

  def load_group
    @group = Group.find(params[:group_id])
  end
end