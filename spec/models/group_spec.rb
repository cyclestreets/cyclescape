# encoding: utf-8

# == Schema Information
#
# Table name: groups
#
#  id          :integer         not null, primary key
#  name        :string(255)     not null
#  short_name  :string(255)     not null
#  website     :string(255)
#  email       :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  disabled_at :datetime
#

require 'spec_helper'

describe Group do
  describe "to be valid" do
    subject { FactoryGirl.build(:group) }

    it "must have a name" do
      subject.name = ""
      subject.should have(1).error_on(:name)
    end

    it "must have a short name" do
      subject.short_name = ""
      subject.should have(1).error_on(:short_name)
    end

    it "must have a default thread privacy" do
      subject.default_thread_privacy = ""
      subject.should have(1).error_on(:default_thread_privacy)
    end
  end

  describe "newly created" do
    subject { FactoryGirl.create(:group) }

    it "must have a profile" do
      subject.profile.should be_valid
    end

    it "should have a default thread privacy of public" do
      subject.default_thread_privacy.should eql("public")
    end

    describe "short name" do
      it "should be unique" do
        subject.should validate_uniqueness_of(:short_name)
      end

      it "should not allow bad characters" do
        ["£","$","%","^","&"].each do |char|
          subject.short_name = char
          subject.should have(1).error_on(:short_name)
        end
      end

      it "should be short enough to be a subdomain" do
        subject.short_name = "c"*64
        subject.should have(1).error_on(:short_name)
      end

      it "should not be an important subdomain" do
        %w{www ftp smtp imap}.each do |d|
          subject.short_name = d
          subject.should have(1).error_on(:short_name)
        end
      end

      it "can't start or end with a hyphen" do
        %w{ -foo foo-}.each do |d|
          subject.short_name = d
          subject.should have(1).error_on(:short_name)
        end
      end
    end
  end

  describe "validations" do
    it { should allow_value("public").for(:default_thread_privacy) }
    it { should allow_value("group").for(:default_thread_privacy) }
    it { should_not allow_value("other").for(:default_thread_privacy) }
  end

  context "members" do
    let(:membership) { FactoryGirl.create(:brian_at_quahogcc) }
    let(:brian) { membership.user }

    subject { membership.group }

    it "should list committee members" do
      subject.committee_members.should include(brian)
    end
  end
end
