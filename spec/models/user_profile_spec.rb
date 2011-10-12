require 'spec_helper'

describe UserProfile do
  context "associations" do
    it { should belong_to(:user) }
  end

  context "picture" do
    subject { FactoryGirl.create(:user_profile) }

    it "should accept and save a picture" do
      subject.picture_uid.should_not be_blank
      subject.picture.mime_type.should == "image/jpeg"
    end

    it "should provide a thumbnail of the picture" do
      subject.picture_thumbnail.should be_true
      subject.picture_thumbnail.width.should == 80
      subject.picture_thumbnail.height.should == 80
    end
  end
end
