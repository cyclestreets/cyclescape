# frozen_string_literal: true



class Hashtagging < ApplicationRecord
  belongs_to :hashtag
  belongs_to :message
end

# == Schema Information
#
# Table name: hashtaggings
#
#  id         :integer          not null, primary key
#  hashtag_id :integer
#  message_id :integer
#
# Indexes
#
#  index_hashtaggings_on_hashtag_id                 (hashtag_id)
#  index_hashtaggings_on_hashtag_id_and_message_id  (hashtag_id,message_id)
#  index_hashtaggings_on_message_id                 (message_id)
#
# Foreign Keys
#
#  fk_rails_...  (hashtag_id => hashtags.id)
#  fk_rails_...  (message_id => messages.id)
#
