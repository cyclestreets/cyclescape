class GroupRequestsController < ApplicationController
  before_filter :load_group_request, only: [:show, :edit, :update, :destroy, :review, :confirm]
  filter_access_to :all, attribute_check: true, model: Group

  def index
    @requests = GroupRequest.order('created_at desc').includes(:user)
  end

  def new
    @request = GroupRequest.build
  end

  def create
    @request.user = current_user

    if @request.save
      redirect_to @group, notice: t('.group_requests.create.requested')
      Notifications.new_group_request(@request).deliver
    else
      render :new
    end
  end

  def review
  end

  def confirm
    @request.actioned_by = current_user
    if @request.confirm
      Notifications.group_request_confirmed(@request).deliver
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to action: :index
  end

  def reject
    @request.actioned_by = current_user
    if @request.reject
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to action: :index
  end

  def cancel
    if @request.user == current_user && @request.cancel
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to @group
  end

  protected

  def load_group_request
    @group = GroupRequest.find(params[:group_id])
  end
end
