class LinkMessage < MessageComponent
  validates :url, url: true, presence: true

  # Normalize URL
  def url=(val)
    write_attribute(:url, AttributeNormaliser::URL.new(val).normalise)
  end
end
