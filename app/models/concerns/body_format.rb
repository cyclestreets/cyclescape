# frozen_string_literal: true

module BodyFormat
  def html?
    html_format_time = Rails.cache.fetch("html_format_time", expires_in: 1.year) do
      ActiveRecord::Base.connection.select_value("SELECT created_at FROM html_issues")
    end
    created_at > html_format_time
  end

  def plain_text?
    !html?
  end
end
