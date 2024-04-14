# frozen_string_literal: true

Thread.current[:redis] ||= Redis.new
