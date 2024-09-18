# frozen_string_literal: true

class MessageThread::TagsController < MessageThread::BaseController
  def update
    authorize @thread, :update_tags?
    if @thread.update(tags_string: params[:message_thread][:tags_string])
      @library_items = Library::Item.find_by_tags_from(@thread).limit(5)
      render json: { tagspanel: TagPanelDecorator.new(@thread, form_url: url_for).render,
                     librarypanel: render_to_string("message_threads/_library_panel", layout: false, locals: { items: @library_items, thread_tags: @thread.tags }) }
    else
      head :conflict
    end
  end
end
