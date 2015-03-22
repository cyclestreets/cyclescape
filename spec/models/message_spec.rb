# == Schema Information
#
# Table name: messages
#
#  id             :integer          not null, primary key
#  created_by_id  :integer          not null
#  thread_id      :integer          not null
#  body           :text             not null
#  component_id   :integer
#  component_type :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#  censored_at    :datetime
#
# Indexes
#
#  index_messages_on_created_by_id  (created_by_id)
#  index_messages_on_thread_id      (thread_id)
#

require 'spec_helper'

describe Message do
  describe 'associations' do
    it { is_expected.to belong_to(:created_by) }
    it { is_expected.to belong_to(:thread) }
    it { is_expected.to belong_to(:component) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:created_by_id) }
    it { is_expected.to validate_presence_of(:body) }

    it 'should not require a body if a component is attached' do
      allow(subject).to receive(:component).and_return(true)
      expect(subject).to have(0).errors_on(:body)
    end
  end

  describe 'newly created' do
    subject { FactoryGirl.create(:message) }

    it 'should not be censored' do
      expect(subject.censored_at).to be_nil
    end
  end

  describe 'component association' do
    subject { FactoryGirl.create(:message) }

    it 'should accept a PhotoMessage' do
      subject.component = FactoryGirl.create(:photo_message, message: subject)
      expect(subject.component_type).to eq('PhotoMessage')
      expect(subject).to be_valid
    end
  end

  describe 'body' do
    it 'should be blank if empty when component is attached' do
      allow(subject).to receive(:component).and_return(true)
      subject.created_by_id = 1
      expect(subject).to be_valid
      expect(subject.body).to eq('')
    end

    it 'should be retained with an attached component' do
      allow(subject).to receive(:component).and_return(true)
      subject.created_by_id = 1
      subject.body = 'Testing'
      expect(subject).to be_valid
      expect(subject.body).to eq('Testing')
    end
  end

  describe '#component_name' do
    it 'should return the name of Message if there is no component' do
      message = FactoryGirl.build(:message)
      expect(message.component_name).to eq('message')
    end

    it 'should return the name of the component' do
      photo_message = FactoryGirl.build(:photo_message)
      message = photo_message.message
      expect(message.component_name).to eq('photo_message')
    end
  end

  describe 'searchable text' do
    it "should return the body if there's no component" do
      message = FactoryGirl.create(:message)
      expect(message.searchable_text).to eq(message.body)
    end

    it "should return both the body and the component's text if there's a component" do
      message = FactoryGirl.create(:photo_message).message
      expect(message.searchable_text).to include(message.body)
      expect(message.searchable_text).to include(message.component.searchable_text)
    end
  end
end
