class Site::CommentsController < ApplicationController
  def new
    @site_comment = SiteComment.new(user: current_user)
  end

  def create
    @site_comment = SiteComment.create!(params[:site_comment])
    render "thank_you"
  end
end
