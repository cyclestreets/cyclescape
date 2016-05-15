class Site::CommentsController < ApplicationController
  def index
    @site_comments = SiteComment.order('created_at desc').page params[:page]
  end

  def new
    @site_comment = current_user ? current_user.site_comments.new : SiteComment.new
  end

  def create
    @site_comment = SiteComment.new permitted_params

    @site_comment.user = current_user if current_user

    if @site_comment.save
      set_flash_message(:success)
      redirect_to request.referer || root_path
    else
      render 'new', status: :conflict
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
    params.require(:site_comment).permit :name, :email, :body, :context_url, :context_data
  end
end
