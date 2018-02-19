# frozen_string_literal: true

class MessageThreadClose < ActiveRecord::Base
  belongs_to :user
  belongs_to :message_thread
end
