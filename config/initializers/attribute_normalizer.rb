AttributeNormalizer.configure do |config|
  config.normalizers[:downcase] = lambda do |text, options|
    if text.is_a?(String)
      text.downcase
    else
      text
    end
  end
end
