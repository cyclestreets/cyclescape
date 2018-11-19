# frozen_string_literal: true

module Route
  class MessageApi < Base
    paginate paginate_settings

    params do
      optional :thread_id, type: Integer, desc: 'ID of thread'
      optional :order, type: Symbol, values: %i[created_at id], desc: 'Order of returned messages.'
      optional :order_direction, type: Symbol, values: %i[asc desc], default: :asc
      optional :end_date, types: [DateTime, Date], desc: 'Only messages after or at the end date or time are returned'
      optional :start_date, types: [DateTime, Date], desc: 'Only messages before or at the start date or time are returned'
    end

    helpers do
      def post_or_get_messages
        scope = Message.joins(:thread).includes(:created_by)
        scope = scope.merge(MessageThread.is_public.approved)
        scope = scope.where(censored_at: nil)
        scope = scope.order(params[:order] => params[:order_direction]) if params[:order]
        scope = scope.where(thread_id: params[:thread_id]) if params[:thread_id]
        scope = scope.before_date(params[:end_date]) if params[:end_date]
        scope = scope.after_date(params[:start_date]) if params[:start_date]
        scope = paginate scope
      end
    end

    resource do
      desc 'Returns messages collection', security: [{}]
      get :messages do
        post_or_get_messages
      end
    end
  end
end
