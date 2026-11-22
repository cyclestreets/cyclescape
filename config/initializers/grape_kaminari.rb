# frozen_string_literal: true

# grape-kaminari 0.4.5 (unmaintained) passes the pagination options to `use` as a
# positional hash; Grape 3 takes them as keywords, so the hash is treated as a
# param-set name and raises "Params :{...} not found!".
require "grape/kaminari"

module Grape
  module Kaminari
    module DSLMethods
      def paginate(opts = {})
        params do
          use(:pagination, **opts)
        end
      end
    end
  end
end
