# == Schema Information
#
# Table name: issue_categories
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe IssueCategory do
  describe "Newly created" do
    subject { FactoryGirl.create(:issue_category) }

    it "must have a name" do
      subject.name.should be_an_instance_of(String)
    end
  end

  describe "to be valid" do
    subject { FactoryGirl.create(:issue_category) }

    it "must have a name" do
      subject.name = nil
      subject.should_not be_valid
    end

    it "must not have a stupidly long name" do
      subject.name = "F"*100
      subject.should_not be_valid
    end

    it { should validate_uniqueness_of(:name) }
  end
end
