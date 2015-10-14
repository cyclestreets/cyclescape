require 'spec_helper'

describe Message do
  describe 'associations' do
    it { is_expected.to belong_to(:created_by) }
    it { is_expected.to belong_to(:thread) }
    it { is_expected.to belong_to(:component) }
    it { is_expected.to belong_to(:in_reply_to) }
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
    subject { create(:message) }

    it 'should not be censored' do
      expect(subject.censored_at).to be_nil
    end

    it 'should have a public token' do
      expect(subject.public_token).to match(/\A[0-9a-f]{20}\Z/)
    end
  end

  describe 'component association' do
    subject { create(:message) }

    it 'should accept a PhotoMessage' do
      subject.component = create(:photo_message, message: subject)
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
      message = build(:message)
      expect(message.component_name).to eq('message')
    end

    it 'should return the name of the component' do
      photo_message = build(:photo_message)
      message = photo_message.message
      expect(message.component_name).to eq('photo_message')
    end
  end

  describe 'searchable text' do
    it "should return the body if there's no component" do
      message = create(:message)
      expect(message.searchable_text).to eq(message.body)
    end

    it "should return both the body and the component's text if there's a component" do
      message = create(:photo_message).message
      expect(message.searchable_text).to include(message.body)
      expect(message.searchable_text).to include(message.component.searchable_text)
    end
  end

  describe 'in reply to' do
    let(:previous_message) { create(:message) }

    it 'sets in reply to with previous message' do
      subject = create(:message, thread: previous_message.thread.reload)
      expect(subject.in_reply_to).to eq(previous_message)
    end

    it 'sets in reply to nil with no previous message' do
      subject = create(:message)
      expect(subject.in_reply_to).to be_nil
    end
  end
end
