# == Schema Information
#
# Table name: link_messages
#
#  id            :integer         not null, primary key
#  thread_id     :integer         not null
#  message_id    :integer         not null
#  created_by_id :integer         not null
#  url           :text            not null
#  title         :string(255)
#  description   :text
#  created_at    :datetime
#

class LinkMessage < MessageComponent
  validates :url, url: true, presence: true

  # Normalize URL
  def url=(val)
    write_attribute(:url, AttributeNormaliser::URL.new(val).normalise)
  end
end
