GrapeSwaggerRails.options.url      = '/api/swagger_doc'
GrapeSwaggerRails.options.before_filter_proc = proc {
  GrapeSwaggerRails.options.app_url = request.protocol + request.host_with_port
}

# grape > 0.16.1 is needed https://github.com/ruby-grape/grape/pull/1325
# but grape-swagger limits grape to older versions (and calls deprecated methods)
# nasty monkey patch to silence the warnings till https://github.com/ruby-grape/grape-swagger/pull/375 is released

module Grape
  class Router
    class Route

      private

      def warn_route_methods(name, location, expected = nil)
        # noop
      end
    end
  end
end
