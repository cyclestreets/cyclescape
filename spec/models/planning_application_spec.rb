require 'spec_helper'

describe PlanningApplication do
  subject        { build(:planning_application) }

  describe "newly created" do
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_uniqueness_of(:uid) }
    it { is_expected.to have_many(:hide_votes) }
    it { is_expected.to have_many(:users).through(:hide_votes) }

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

    it 'should populate an issue' do
      subject.save!
      issue = subject.populate_issue
      expect(issue.title).to include(subject.title)
      expect(issue.description).to include(subject.description)
      expect(issue.location).to eq(subject.location)
      expect(issue.external_url).to eq(subject.url)
    end
  end

  context "with an issue" do
    subject { create(:planning_application, :with_issue) }

    it "should have an issue" do
      expect(subject.issue).to_not be_nil
    end
  end

  it 'should have an ordered scope' do
    subject.save!
    expect(described_class.ordered.count).to eq(1)
  end

  context 'with one vote to hide' do
    before do
      subject.save!
      create(:hide_vote, planning_application: subject)
    end

    it 'should be part hidden' do
      expect(subject.reload.part_hidden?).to be true
    end
  end

  context 'with two votes to hide' do
    before do
      subject.save!
      2.times { create(:hide_vote, planning_application: subject) }
    end

    it 'should have be fully hidden' do
      expect(subject.reload.fully_hidden?).to be true
    end
  end


  it 'should have an not hidden scope' do
    not_hidden = create(:planning_application)

    once_hidden = create(:planning_application)
    create(:hide_vote, planning_application: once_hidden)

    twice_hidden = create(:planning_application)
    create(:hide_vote, planning_application: twice_hidden)
    create(:hide_vote, planning_application: twice_hidden)

    not_hidden = described_class.not_hidden
    expect(not_hidden.size).to eq(2)
    expect(not_hidden).to_not include(twice_hidden)
  end

  context 'with old planning applications' do
    before do
      create(:planning_application, created_at: 9.months.ago)
      create(:planning_application, :with_issue, created_at: 9.months.ago)
      create(:planning_application, created_at: 7.months.ago)
    end

    it 'should remove old planning applications more than 8 months old' do
      expect{ described_class.remove_old }.to change{ described_class.count }.from(3).to(2)
    end
  end

  describe '#relevant?' do
    it 'should be true outside Cambridge' do
      subject.authority_name = 'Leeds'
      subject.save
      expect(subject.relevant).to be true
    end

    %w(LBC FUL CL2PD PRP11 GPE NMA S73 0173 DEMDET REM B1C3 OUT TELDET EXP).each do |ending|
      it "should be true with #{ending} uids inside Cambridge" do
        subject.authority_name = 'Cambridge'
        subject.uid = "00/0000/#{ending}"
        subject.save
        expect(subject.relevant).to be true
      end
    end

    %w(TTCA TTPO COND3 COND53C CLUED ADV CON6 CON18).each do |ending|
      it "should be flase with #{ending} uids inside Cambridge" do
        subject.authority_name = 'Cambridge'
        subject.uid = "00/0000/#{ending}"
        subject.save
        expect(subject.relevant).to be false
      end
    end
  end
end
