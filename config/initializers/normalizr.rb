# frozen_string_literal: true

Normalizr.configure do
  add :url do |value|
    text = value.respond_to?(:strip) ? value.strip : value

    if text.blank? || text =~ %r{\A.*://}
      text
    else
      "http://#{text}"
    end
  end

  add :downcase do |text|
    if text.is_a?(String)
      text.downcase
    else
      text
    end
  end

  add :strip_html_paragraphs do |value|
    next value unless value.is_a? String

    value.gsub(%r{\s*<p>([[:space:]]|&nbsp;|<br>)*?</p>}, "")
  end

  add :strip_fb_links do |value|
    next unless value.is_a? String

    value.split.select { |word| word.include? "fbclid=" }.each do |url|
      begin
        uri = Addressable::URI.parse(url)
      rescue Addressable::URI::InvalidURIError
        next
      end
      params = uri.query_values
      params.delete("fbclid")
      uri.query_values = params
      value = value.gsub(url, uri.to_s)
    end
    value
  end
end
