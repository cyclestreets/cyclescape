# frozen_string_literal: true

class Issue::TagsController < BaseTagsController
  private

  def resource
    @resource ||= Issue.find params[:issue_id]
  end
end
