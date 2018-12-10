AttributeNormalizer.configure do |config|
  config.normalizers[:url] = lambda do |value, _options|
    text = value.respond_to?(:strip) ? value.strip : value

    if text.blank? || text =~ %r{\A.*://}
      text
    else
      "http://#{text}"
    end
  end

  config.normalizers[:downcase] = lambda do |text, _options|
    if text.is_a?(String)
      text.downcase
    else
      text
    end
  end
end
