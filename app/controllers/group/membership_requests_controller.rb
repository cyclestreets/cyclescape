class Group::MembershipRequestsController < ApplicationController
  before_filter :load_group

  def index
    @requests = @group.membership_requests.order("created_at desc")
  end

  def new
    @request = @group.membership_requests.build
  end

  def create
    @request = @group.membership_requests.build({user: current_user})

    if @request.save
      redirect_to @group, notice: t(".groups.membership_requested")
    else
      render :new
    end
  end

  def confirm
    @request = @group.membership_requests.find(params[:id])
    @request.actioned_by = current_user
    if @request.confirm
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