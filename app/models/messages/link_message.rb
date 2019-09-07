# frozen_string_literal: true


class LinkMessage < MessageComponent
  validates :url, url: true, presence: true
  normalize_attribute :url, with: :url
end

# == Schema Information
#
# Table name: link_messages
#
#  id            :integer          not null, primary key
#  description   :text
#  title         :string(255)
#  url           :text             not null
#  created_at    :datetime
#  updated_at    :datetime
#  created_by_id :integer          not null
#  message_id    :integer          not null
#  thread_id     :integer          not null
#
# Indexes
#
#  index_link_messages_on_created_by_id  (created_by_id)
#  index_link_messages_on_message_id     (message_id)
#  index_link_messages_on_thread_id      (thread_id)
#
