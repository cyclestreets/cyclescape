# frozen_string_literal: true

class Issue::TagsController < ApplicationController
  def update
    @issue = Issue.find params[:issue_id]
    authorize @issue, :update_tags?
    if @issue.update tags_string: params[:issue][:tags_string]
      render json: { tagspanel: TagPanelDecorator.new(@issue, form_url: url_for).render }
    else
      head :conflict
    end
  end
end
