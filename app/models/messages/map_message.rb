# frozen_string_literal: true

class MapMessage < MessageComponent
  include Locatable
  validates :location, presence: true
end

# == Schema Information
#
# Table name: map_messages
#
#  id            :integer          not null, primary key
#  caption       :text
#  location      :geometry({:srid= not null, geometry, 4326
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer          not null
#  message_id    :integer          not null
#  thread_id     :integer          not null
#
# Indexes
#
#  index_map_messages_on_created_by_id  (created_by_id)
#  index_map_messages_on_message_id     (message_id)
#  index_map_messages_on_thread_id      (thread_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (message_id => messages.id)
#  fk_rails_...  (thread_id => message_threads.id)
#
