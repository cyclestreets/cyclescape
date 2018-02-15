# frozen_string_literal: true

class Hashtagging < ActiveRecord::Base
  belongs_to :hashtag
  belongs_to :message
end
