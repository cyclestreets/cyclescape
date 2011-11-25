class Issue::TagsController < ApplicationController
  def update
    @issue = Issue.find(params[:issue_id])
    if @issue.update_attributes(tags_string: params[:issue][:tags_string])
      render partial: "panel", locals: {issue: @issue}
    else
      head :conflict
    end
  end
end
