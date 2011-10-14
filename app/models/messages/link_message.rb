class LinkMessage < MessageComponent
  validates :url, presence: true, format: {with: /\A#{URI::regexp(%w(http https))}\Z/}

  # Normalize URL
  def url=(val)
    val = "http://#{val}" unless val.nil? or val =~ %r{\A.*://}
    write_attribute(:url, val)
  end
end
