class MessageThread::TagsController < MessageThread::BaseController
  def update
    if @thread.update_attributes(tags_string: params[:message_thread][:tags_string])
      render text: TagPanelDecorator.new(@thread, form_url: url_for).render
    else
      head :conflict
    end
  end
end
