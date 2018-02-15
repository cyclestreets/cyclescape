# frozen_string_literal: true

AttributeNormalizer.configure do |config|
  config.normalizers[:downcase] = lambda do |text, _options|
    if text.is_a?(String)
      text.downcase
    else
      text
    end
  end
end
