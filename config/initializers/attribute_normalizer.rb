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
    html = Nokogiri::HTML::DocumentFragment.parse value
    html.css("p").reverse.each do |node|
      if node.inner_text.blank?
        node.remove
      else
        break
      end
    end
    html.to_html.strip
  end
end
