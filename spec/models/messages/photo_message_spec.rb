require "spec_helper"

describe PhotoMessage do
  describe "associations" do
    it { should belong_to(:message) }
    it { should belong_to(:thread) }
    it { should belong_to(:created_by) }
  end

  describe "validations" do
    it { should validate_presence_of(:photo) }
  end

  context "factory" do
    subject { FactoryGirl.create(:photo_message) }

    it { should be_valid }

    it "should have a thread" do
      subject.thread.should be_a(MessageThread)
    end

    it "should have a message" do
      subject.message.should be_a(Message)
    end
  end
end
