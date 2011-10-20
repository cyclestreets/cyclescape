# == Schema Information
#
# Table name: message_threads
#
#  id            :integer         not null, primary key
#  issue_id      :integer
#  created_by_id :integer         not null
#  group_id      :integer
#  title         :string(255)     not null
#  description   :text            not null
#  privacy       :string(255)     not null
#  state         :string(255)     not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

require 'spec_helper'

describe MessageThread do
  describe "associations" do
    it { should belong_to(:created_by) }
    it { should belong_to(:group) }
    it { should belong_to(:issue) }
    it { should have_many(:messages) }
    it { should have_many(:subscriptions) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:created_by_id) }
    it { should allow_value("public").for(:privacy) }
    it { should allow_value("group").for(:privacy) }
    it { should_not allow_value("other").for(:privacy) }
  end

  describe "privacy" do
    subject { MessageThread.new }

    it "should become private to group" do
      subject.should_not be_private_to_group
      subject.group = FactoryGirl.create(:group)
      subject.privacy = "group"
      subject.should be_private_to_group
    end

    it "should be public" do
      subject.should_not be_public
      subject.privacy = "public"
      subject.should be_public
    end
  end
end
