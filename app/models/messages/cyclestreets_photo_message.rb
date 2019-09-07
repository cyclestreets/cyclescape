# frozen_string_literal: true



class CyclestreetsPhotoMessage < MessageComponent
  include Photo
  include Locatable

  validates :location, :photo, presence: true

  def searchable_text
    caption
  end
end

# == Schema Information
#
# Table name: cyclestreets_photo_messages
#
#  id              :integer          not null, primary key
#  caption         :text
#  icon_properties :json
#  location        :geometry({:srid= not null, geometry, 4326
#  photo_name      :string
#  photo_uid       :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  created_by_id   :integer          not null
#  cyclestreets_id :integer
#  message_id      :integer          not null
#  thread_id       :integer          not null
#
# Indexes
#
#  index_cyclestreets_photo_messages_on_created_by_id  (created_by_id)
#  index_cyclestreets_photo_messages_on_message_id     (message_id)
#  index_cyclestreets_photo_messages_on_thread_id      (thread_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (message_id => messages.id)
#  fk_rails_...  (thread_id => message_threads.id)
#
