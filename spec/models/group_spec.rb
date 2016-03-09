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
      create :group
      expect(described_class.ordered.count).to eq 1
    end
  end

  describe 'newly created' do
    subject { create(:group) }

    it 'must have a profile' do
      expect(subject.profile).to be_valid
    end

    it 'should have a default thread privacy of public' do
      expect(subject.default_thread_privacy).to eql('public')
    end

    describe 'short name' do
      it 'should be unique' do
        expect(subject).to validate_uniqueness_of(:short_name)
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
end
