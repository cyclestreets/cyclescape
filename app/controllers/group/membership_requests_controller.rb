class Group::MembershipRequestsController < ApplicationController
  before_filter :load_group

  def index
    @requests = @group.membership_requests.order("created_at desc")
  end

  def new
    @request = @group.membership_requests.build
  end

  def create
    if current_user.groups.include?(@group)
      redirect_to @group, alert: t(".group.membership_requests.create.already_member")
    elsif current_user.membership_requests.where(group_id: @group.id).count > 0
      redirect_to @group, alert: t(".group.membership_requests.create.already_asked")
    else
      @request = @group.membership_requests.build({user: current_user})

      if @request.save
        redirect_to @group, notice: t(".group.membership_requests.create.requested")
      else
        render :new
      end
    end
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