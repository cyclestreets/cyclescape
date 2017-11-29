module Route
  class ThreadApi < Base
    paginate paginate_settings

    params do
      optional :group, type: String, desc: 'Return only issues from area of group given by its short name, e.g. "london"'
      optional :issue_id, type: Integer, desc: 'ID of issue'
      optional :order_by, type: Symbol, values:%i( created_at id  ), desc: 'Order of returned issues.'
      optional :order, type: Symbol, values:%i(asc desc), default: :asc
    end

    helpers do
      def post_or_get_thread
        scope = MessageThread.is_public.approved.includes(:messages)
        if params[:group]
          group = Group.find_by(short_name: params[:group])
          error! 'Given group not found', 404 unless group
          scope = scope.intersects(group.profile.location)
        end
        scope = scope.order(params[:order_by] => params[:order]) if params[:order_by]
        scope = scope.where(issue_id: params[:issue_id]) if params[:issue_id]
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
