# frozen_string_literal: true

module Route
  class Base < Grape::API
    include Grape::Kaminari

    def self.paginate_settings
      { per_page: 200, max_per_page: 500, offset: false }
    end
  end
end
