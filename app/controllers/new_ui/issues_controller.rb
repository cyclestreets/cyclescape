# frozen_string_literal: true

module NewUi
  class IssuesController < BaseController
    def index
      @issues = Issue.preloaded.by_most_recent.page(params[:page])
    end
  end
end
