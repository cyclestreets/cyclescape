# frozen_string_literal: true

class Site::CommentsController < ApplicationController
  def index
    @site_comments = SiteComment.order("created_at desc").page params[:page]
  end

  def new
    session[:site_comment_referer] = request.referer
    @site_comment = current_user ? current_user.site_comments.new : SiteComment.new
  end

  def create
    @site_comment = SiteComment.new permitted_params

    @site_comment.user = current_user
    @site_comment.context_url = session[:site_comment_referer]

    if params[:bicycle_wheels].try(:strip) == "8" && params[:real_name].blank? && @site_comment.save
      set_flash_message(:success)
      AdminMailer.new_site_comment(@site_comment).deliver_later
      redirect_to session[:site_comment_referer] || root_path
      session[:site_comment_referer] = nil
    else
      render "new", status: :conflict
    end
  end

  def destroy
    @site_comment = SiteComment.find params[:id]

    if @site_comment.destroy
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
  end

  protected

  def permitted_params
    params.require(:site_comment).permit :name, :email, :body, :context_url
  end
end
