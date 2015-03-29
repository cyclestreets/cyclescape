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
  subject        { FactoryGirl.build(:planning_application) }

  describe "newly created" do
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

  it 'should have an ordered scope' do
    subject.save!
    expect(described_class.ordered.count).to eq(1)
  end

  it 'should have an not hidden scope' do
    not_hidden = FactoryGirl.create(:planning_application)

    once_hidden = FactoryGirl.create(:planning_application)
    FactoryGirl.create(:hide_vote, planning_application: once_hidden)

    twice_hidden = FactoryGirl.create(:planning_application)
    FactoryGirl.create(:hide_vote, planning_application: twice_hidden)
    FactoryGirl.create(:hide_vote, planning_application: twice_hidden)

    not_hidden = described_class.not_hidden
    expect(not_hidden.size).to eq(2)
    expect(not_hidden).to_not include(twice_hidden)
  end

  context 'with old planning applications' do
    before do
      FactoryGirl.create(:planning_application, created_at: 9.months.ago)
      FactoryGirl.create(:planning_application, :with_issue, created_at: 9.months.ago)
      FactoryGirl.create(:planning_application, created_at: 7.months.ago)
    end

    it 'should remove old planning applications more than 8 months old' do
      expect{ described_class.remove_old }.to change{ described_class.count }.from(3).to(2)
    end
  end
end
