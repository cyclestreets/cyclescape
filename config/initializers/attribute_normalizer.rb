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

  config.normalizers[:strip_html_paragraphs] = lambda do |value, _options|
    return value unless value.is_a? String
    value.gsub(%r{(\s*<p>\s*&nbsp;\s*</p>\s*)*\z}, "")
  end

  config.normalizers[:strip_fb_links] = lambda do |value, _options|
    return unless value.is_a? String
    value.split.select { |word| word.include? "fbclid=" }.each do |url|
      begin
        uri = Addressable::URI.parse(url)
      rescue Addressable::URI::InvalidURIError
        next
      end
      params = uri.query_values
      params.delete('fbclid')
      uri.query_values = params
      value = value.gsub(url, uri.to_s)
    end
    value
  end
end
