class Group::PrefsController < ApplicationController
  before_filter :load_group
  filter_access_to :edit, :update, attribute_check: true, model: Group

  def edit
    @prefs = @group.prefs

    @membership_secretary_candidates = @group.committee_members
  end

  def update
    @prefs = @group.prefs
    if @prefs.update permitted_params
      set_flash_message :success
    else
      set_falsh_message :failure
    end
    redirect_to action: 'edit'
  end

  protected

  def load_group
    @group = Group.find params[:group_id]
  end

  def permitted_params
    params.require(:group_pref).permit :membership_secretary_id, :notify_membership_requests
  end
end
