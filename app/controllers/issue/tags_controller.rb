# frozen_string_literal: true

class Issue::TagsController < ApplicationController
  def edit
    issue = Issue.find params[:issue_id]
    authorize issue, :update_tags?
    render turbo_stream: turbo_stream.replace(helpers.dom_id(issue, :tags), partial: "shared/edit_tags", locals: { resource: issue })
  end

  def update
    issue = Issue.find params[:issue_id]
    authorize issue, :update_tags?
    if issue.update tags_string: params[:issue][:tags_string]
      render turbo_stream: turbo_stream.replace(helpers.dom_id(issue, :tags), partial: "shared/tags/widget_content", locals: { resource: issue })
    else
      head :conflict
    end
  end
end
