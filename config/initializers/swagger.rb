GrapeSwaggerRails.options.url      = '/api/swagger_doc'
GrapeSwaggerRails.options.before_filter_proc = proc {
  GrapeSwaggerRails.options.app_url = request.protocol + request.host_with_port
}
