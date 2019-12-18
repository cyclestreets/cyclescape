# frozen_string_literal: true

class StreetViewMessage < MessageComponent
  validates :caption, :heading, :pitch, :location, presence: true

  def location_string=(location_string)
    y, x = location_string.gsub(/[()]/, "").split(",").map &:to_f
    self.location = RGeo::Geos.factory(srid: 4326).point(x, y)
  end

  def location_string; end
end

# == Schema Information
#
# Table name: street_view_messages
#
#  id            :integer          not null, primary key
#  caption       :text
#  heading       :decimal(, )
#  location      :geometry({:srid= geometry, 4326
#  pitch         :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer
#  message_id    :integer
#  thread_id     :integer
#
# Indexes
#
#  index_street_view_messages_on_created_by_id  (created_by_id)
#  index_street_view_messages_on_location       (location) USING gist
#  index_street_view_messages_on_message_id     (message_id)
#  index_street_view_messages_on_thread_id      (thread_id)
#
