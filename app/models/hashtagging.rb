# frozen_string_literal: true

class Hashtagging < ApplicationRecord
  belongs_to :hashtag
  belongs_to :message
end
