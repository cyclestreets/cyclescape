class Site::CommentsController < ApplicationController
  def index
    @site_comments = SiteComment.order("created_at desc").page(params[:page])
  end

  def new
    @site_comment = SiteComment.new(user: current_user)
  end

  def create
    @site_comment = SiteComment.new(params[:site_comment])

    if @site_comment.save
      render "success"
    else
      render "new", status: :conflict
    end
  end
end
