# frozen_string_literal: true

class MessageThreadClose < ApplicationRecord
  belongs_to :user
  belongs_to :message_thread
end
