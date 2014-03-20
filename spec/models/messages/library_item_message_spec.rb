# == Schema Information
#
# Table name: library_item_messages
#
#  id              :integer          not null, primary key
#  thread_id       :integer          not null
#  message_id      :integer          not null
#  library_item_id :integer          not null
#  created_by_id   :integer
#

require 'spec_helper'

describe LibraryItemMessage do
  it 'should be valid' do
    message = FactoryGirl.create(:library_item_message_with_document)
    message.should be_valid
  end
end
