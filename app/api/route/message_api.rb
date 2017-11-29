module Route
  class MessageApi < Base
    paginate paginate_settings

    params do
      optional :thread_id, type: Integer, desc: 'ID of thread'
      optional :order_by, type: Symbol, values:%i( created_at id  ), desc: 'Order of returned issues.'
      optional :order, type: Symbol, values:%i(asc desc), default: :asc
    end

    helpers do
      def post_or_get_messages
        scope = Message.joins(:thread).includes(:created_by)
        scope = scope.merge(MessageThread.is_public.approved)
        scope = scope.where(censored_at: nil)
        scope = scope.order(params[:order_by] => params[:order]) if params[:order_by]
        scope = scope.where(thread_id: params[:thread_id]) if params[:thread_id]
        scope = paginate scope
      end
    end

    resource do
      desc 'Returns messages collection'
      get :messages do
        post_or_get_messages
      end
    end
  end
end
