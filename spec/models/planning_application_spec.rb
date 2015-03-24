# == Schema Information
#
# Table name: planning_applications
#
#  id                      :integer         not null, primary key
#  openlylocal_id          :integer         not null
#  openlylocal_url         :string(255)
#  address                 :string(255)
#  postcode                :string(255)
#  description             :text
#  council_name            :string(255)
#  openlylocal_council_url :string(255)
#  url                     :string(255)
#  uid                     :string(255)     not null
#  issue_id                :integer
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#  location                :spatial({:srid=
#

require 'spec_helper'

describe PlanningApplication do
  describe "newly created" do
    subject { FactoryGirl.create(:planning_application) }
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:location) }
    it { is_expected.to validate_uniqueness_of(:uid) }

    it "should not have an issue" do
      expect(subject.issue).to be_nil
    end

    it "should have an appropriate title" do
      expect(subject.title).to include(subject.uid)
      expect(subject.title).to include(subject.description)
    end

    it "should have an appropriate title when there's no description" do
      subject.description = nil
      expect(subject.title).to include(subject.uid)
      expect(subject.title).to include(subject.authority_name)
    end
  end

  context "with an issue" do
    subject { FactoryGirl.create(:planning_application, :with_issue) }

    it "should have an issue" do
      expect(subject.issue).to_not be_nil
    end
  end
end
