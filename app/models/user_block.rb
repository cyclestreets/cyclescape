# frozen_string_literal: true



class UserBlock < ApplicationRecord
  belongs_to :user
  belongs_to :blocked, class_name: "User"
end

# == Schema Information
#
# Table name: user_blocks
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  blocked_id :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_user_blocks_on_blocked_id_and_user_id  (blocked_id,user_id) UNIQUE
#  index_user_blocks_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (blocked_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
