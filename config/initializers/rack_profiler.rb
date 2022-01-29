# frozen_string_literal: true

if defined? Rack::MiniProfilerRails
  Rack::MiniProfiler.config.max_traces_to_show = 500
  Rack::MiniProfiler.config.skip_paths = ["/media/"]
end
