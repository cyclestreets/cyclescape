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

  context "photo thumbnail" do
    subject { FactoryGirl.create(:photo_message) }

    it "should provide a thumbnail of the photo" do
      subject.photo_thumbnail.should be_true
      subject.photo_thumbnail.width.should == 46
      subject.photo_thumbnail.height.should == 50
    end
  end

  context "photo preview" do
    subject { FactoryGirl.create(:photo_message) }

    it "should provide a preview size of the photo" do
      subject.photo_preview.should be_true
      subject.photo_preview.width.should == 182
      subject.photo_preview.height.should == 200
    end
  end
end
