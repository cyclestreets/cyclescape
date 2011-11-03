# == Schema Information
#
# Table name: user_profiles
#
#  id          :integer         not null, primary key
#  user_id     :integer         not null
#  picture_uid :string(255)
#  website     :string(255)
#  about       :text
#

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
      subject.picture_thumbnail.width.should == 50
      subject.picture_thumbnail.height.should == 50
    end

    it "should not accept a text document for a picture" do
      subject.should have(0).errors_on(:picture)
      subject.picture = File.open(lorem_ipsum_path)
      subject.should have(1).error_on(:picture)
    end
  end
end
