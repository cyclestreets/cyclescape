class Issue::TagsController < ApplicationController
  def update
    @issue = Issue.find params[:issue_id]
    if @issue.update_columns tags_string: params[:issue][:tags_string]
      render json: { tagspanel: TagPanelDecorator.new(@issue, form_url: url_for).render }
    else
      head :conflict
    end
  end
end
