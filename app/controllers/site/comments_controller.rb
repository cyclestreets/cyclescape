class Site::CommentsController < ApplicationController
  def index
    @site_comments = SiteComment.order("created_at desc").page(params[:page])
  end

  def new
    @site_comment = current_user ? current_user.site_comments.new : SiteComment.new
  end

  def create
    @site_comment = SiteComment.new(params[:site_comment])

    @site_comment.user = current_user if current_user

    if @site_comment.save
      render "success"
    else
      render "new", status: :conflict
    end
  end
end
