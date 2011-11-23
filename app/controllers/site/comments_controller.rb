class Site::CommentsController < ApplicationController
  def index
    @site_comments = SiteComment.order("created_at desc")
  end

  def new
    @site_comment = SiteComment.new(user: current_user)
  end

  def create
    @site_comment = SiteComment.create!(params[:site_comment])
    render "success"
  end
end
