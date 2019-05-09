# frozen_string_literal: true

# == Schema Information
#
# Table name: street_view_messages
#
#  id            :integer          not null, primary key
#  message_id    :integer
#  thread_id     :integer
#  created_by_id :integer
#  heading       :decimal(, )
#  pitch         :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  location      :spatial          geometry, 4326
#  caption       :text
#
# Indexes
#
#  index_street_view_messages_on_location    (location)
#  index_street_view_messages_on_message_id  (message_id)
#  index_street_view_messages_on_thread_id   (thread_id)
#

class StreetViewMessage < MessageComponent
  validates :caption, :heading, :pitch, :location, presence: true

  def set_location(location_string)
    y, x = location_string.gsub(/[()]/, "").split(",").map &:to_f
    self.location = RGeo::Geos.factory(srid: 4326).point(x, y)
  end
end
