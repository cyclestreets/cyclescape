module Route
  class ThreadApi < Base
    paginate paginate_settings

    params do
      optional :group, type: String, desc: 'Return only issues from area of group given by its short name, e.g. "london"'
      optional :issue_id, type: Integer, desc: 'ID of issue'
      optional :order, type: Symbol, values: %i[created_at id], desc: 'Order of returned threads.'
      optional :order_direction, type: Symbol, values: %i[asc desc], default: :asc
      optional :end_date, types: [DateTime, Date], desc: 'Only threads after or at the end date or time are returned'
      optional :start_date, types: [DateTime, Date], desc: 'Only threads before or at the start date or time are returned'
      optional :after_id, types: Integer, desc: 'Only threads with ID greather than this are returned'
    end

    helpers do
      def post_or_get_thread
        scope = MessageThread.is_public.approved.includes(:messages)
        if params[:group]
          group = Group.find_by(short_name: params[:group])
          error! 'Given group not found', 404 unless group
          scope = scope.intersects(group.profile.location)
        end
        scope = scope.order(params[:order] => params[:order_direction]) if params[:order]
        scope = scope.where(issue_id: params[:issue_id]) if params[:issue_id]
        scope = scope.before_date(params[:end_date]) if params[:end_date]
        scope = scope.after_date(params[:start_date]) if params[:start_date]
        scope = scope.after_id(params[:after_id]) if params[:after_id]
        scope = paginate scope
      end
    end

    resource do
      desc 'Returns threads collection'
      get :threads do
        post_or_get_thread
      end
    end
  end
end
