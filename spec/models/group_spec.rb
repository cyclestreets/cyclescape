# encoding: utf-8
require 'spec_helper'

describe Group do
  describe 'to be valid' do
    subject { build(:group) }

    it 'must have a name' do
      subject.name = ''
      expect(subject).to have(1).error_on(:name)
    end

    it 'must have a short name' do
      subject.short_name = ''
      expect(subject).to have(1).error_on(:short_name)
    end

    it 'must have a default thread privacy' do
      subject.default_thread_privacy = ''
      expect(subject).to have(1).error_on(:default_thread_privacy)
    end
  end

  describe 'scopes' do
    it 'has ordered scope' do
      group = create :group
      group_with_messages = create :group
      create :message_thread, group: group_with_messages
      expect(described_class.ordered).to eq [group_with_messages, group]
    end
  end

  it ".from_geo_or_name" do
    expect(described_class.from_geo_or_name("")).to be_blank
  end

  it ".from_geo_name" do
    stub_request(:get, %r{https://api\.cyclestreets\.net/v2/geocoder\?key=.*&q=leeds}).
      with(:headers => {'Accept' => 'application/json'}).
      to_return(
        status: 200, body: <<-JSON
          {
              "type": "FeatureCollection",
              "features": [
                  {
                      "type": "Feature",
                      "properties": {
                          "name": "Leeds",
                          "near": "Yorkshire and the Humber, England",
                          "bbox": "-0.04,52.289,-0.01,52.29"
                      },
                      "geometry": {
                          "type": "Point",
                          "coordinates": [
                              -1.5437941,
                              53.7974185
                          ]
                      }
                  }
              ]
          }
      JSON
      )
    quahogc_profile = create(:quahogcc_group_profile)
    leeds = create(:group, name: "LEEDS")

    expect(described_class.from_geo_or_name("leeds")).to match_array [quahogc_profile.group, leeds]
  end

  describe 'newly created' do
    subject { create(:group) }

    it 'must have a profile' do
      expect(subject.profile).to be_valid
      expect(subject.profile.new_user_email).to include "Hi {{full_name}},\n #{subject.name} has added you to their Cyclescape group http://"
    end

    it 'should have a default thread privacy of public' do
      expect(subject.default_thread_privacy).to eql('public')
    end

    describe 'short name' do
      it 'should be unique' do
        expect(subject).to validate_uniqueness_of(:short_name).ignoring_case_sensitivity
      end

      it 'should not allow bad characters' do
        ['£', '$', '%', '^', '&'].each do |char|
          subject.short_name = char
          expect(subject).to have(1).error_on(:short_name)
        end
      end

      it 'should be short enough to be a subdomain' do
        subject.short_name = 'c' * 64
        expect(subject).to have(1).error_on(:short_name)
      end

      it 'should not be an important subdomain' do
        %w{www ftp smtp imap munin}.each do |d|
          subject.short_name = d
          expect(subject).to have(1).error_on(:short_name)
        end
      end

      it "can't contain a hyphen" do
        %w{ -foo foo-}.each do |d|
          subject.short_name = d
          expect(subject).to have(1).error_on(:short_name)
        end
      end
    end
  end

  describe 'validations' do
    subject { create(:group) }

    it { is_expected.to allow_value('public').for(:default_thread_privacy) }
    it { is_expected.to allow_value('group').for(:default_thread_privacy) }
    it { is_expected.not_to allow_value('other').for(:default_thread_privacy) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  context 'members' do
    let(:membership) { create(:brian_at_quahogcc) }
    let(:brian) { membership.user }

    subject { membership.group }

    it 'should list committee members' do
      expect(subject.committee_members).to include(brian)
    end

    describe '#has_member?' do
      it 'should be true for Brian' do
        expect(subject.has_member?(brian)).to be_truthy
      end

      it 'should be false for another user' do
        new_user = create(:user)
        expect(subject.has_member?(new_user)).to be_falsey
      end
    end

    describe 'thread privacy options' do
      it 'should include committee for brian' do
        expect(subject.thread_privacy_options_for(brian)).to include('committee')
      end

      it 'should not include committee for another user' do
        new_user = create(:user)
        expect(subject.thread_privacy_options_for(new_user)).not_to include('committee')
      end
    end
  end

  describe "#active_user_counts" do
    subject { create(:group) }
    let(:thread_1) { create(:message_thread, group: subject) }
    let(:thread_2) { create(:message_thread, group: subject) }
    let(:active_poster) { create(:group_membership, group: subject).user  }
    let(:quiet_poster) { create(:group_membership, group: subject).user  }
    let(:not_in_group) { create :user }

    before do
      create_list(:message, 2, thread: thread_1, created_by: active_poster)
      create_list(:message, 2, thread: thread_1, created_by: not_in_group)
      create_list(:message, 3, thread: thread_2, created_by: active_poster)
      create_list(:message, 1, thread: thread_2, created_by: quiet_poster)
      create_list(:message, 1, thread: thread_2, created_by: quiet_poster, created_at: 2.years.ago)
    end

    it "returns the top N with counts" do
      expect(subject.active_user_counts).to eq([
        { user: active_poster, count: 5 },
        { user: quiet_poster, count: 1 }
      ])

      expect(subject.active_user_counts(since: 1.hour.ago, limit: 1)).to eq([
        { user: active_poster, count: 5 }
      ])
    end
  end
end
