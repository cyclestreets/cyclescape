# frozen_string_literal: true

module Route
  class TagApi < Base
    desc 'Returns tags used on issues, library items and threads'
    paginate paginate_settings

    get :tags do
      paginate(Kaminari.paginate_array(Tag.top_tags(500)))
    end
  end
end
