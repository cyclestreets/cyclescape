# == Schema Information
#
# Table name: user_profiles
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
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

  context "url" do
    subject { FactoryGirl.create(:user_profile) }

    it "should allow a valid URL with HTTP protocol" do
      subject.website = "http://en.wikipedia.org/wiki/Family_Guy"
      subject.should have(0).errors_on(:website)
    end

    it "should allow a valid URL with HTTPS protocol" do
      subject.website = "https://en.wikipedia.org/wiki/Family_Guy"
      subject.should have(0).errors_on(:website)
    end

    it "should allow a valid URL without protocol" do
      subject.website = "en.wikipedia.org/wiki/Family_Guy"
      subject.should have(0).errors_on(:website)
    end

    it "should prefix the HTTP protocol on a URL without protocol" do
      subject.website = "en.wikipedia.org/wiki/Family_Guy"
      subject.website.should == "http://en.wikipedia.org/wiki/Family_Guy"
    end

    it "should not allow a URL with FTP protocol" do
      subject.website = "ftp://en.wikipedia.org/wiki/Family_Guy"
      subject.should have(1).error_on(:website)
    end

    it "should not allow an invalid URL" do
      subject.website = "w[iki]pedia.org/wiki/Family_Guy"
      subject.should have(1).error_on(:website)
    end

    it "should accept a blank url" do
      subject.website = ""
      subject.website.should === ""
      subject.should have(0).errors_on(:website)
    end
  end
end
