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

    it "should have an openlylocal id" do
      subject.openlylocal_id.should_not be_nil
    end

    it "should not have an issue" do
      subject.issue.should be_nil
    end

    it "should have an appropriate title" do
      subject.title.should include(subject.uid)
      subject.title.should include(subject.description)
    end

    it "should have an appropriate title when there's no description" do
      subject.description = ""
      subject.title.should include(subject.uid)
      subject.title.should include(subject.council_name)
    end
  end

  describe "to be valid" do
    subject { FactoryGirl.create(:planning_application) }

    it "should have a location" do
      subject.location = ""
      subject.should_not be_valid
    end
  end

  context "with an issue" do
    subject { FactoryGirl.create(:planning_application, :with_issue) }

    it "should have an issue" do
      subject.issue.should_not be_nil
    end
  end
end
