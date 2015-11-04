require 'spec_helper'

describe MessageComponent, type: :model do
  subject { build(:document_message) }

  it 'should have a notification name' do
    expect(subject.notification_name).to eq :new_document_message
  end
end
