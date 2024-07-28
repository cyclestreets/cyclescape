# frozen_string_literal: true

class Group::PrefsController < ApplicationController
  before_action :load_group

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
    redirect_to action: "edit"
  end

  protected

  def load_group
    @group = Group.find params[:group_id]
    authorize @group, :in_group_committee?
  end

  def permitted_params
    params.require(:group_pref).permit :membership_secretary_id, :notify_membership_requests
  end
end
