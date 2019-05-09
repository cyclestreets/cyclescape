# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors[attribute] << :invalid_url unless value.match(/\A#{URI.regexp(%w[http https])}\Z/)
  end
end
