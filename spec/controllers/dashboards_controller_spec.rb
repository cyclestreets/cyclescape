require 'spec_helper'

describe DashboardsController, type: :controller do

  describe 'search', solr: true do
    let!(:public_thread)    { create(:message_thread, :approved, title: 'Public Bananas Thread') }
    let!(:group_thread)     { create(:message_thread, :approved, :private, group: group, title: 'Group Bananas Thread') }
    let!(:committee_thread) { create(:message_thread, :approved, :committee, group: group, title: 'Committee Bananas Thread') }
    let(:group)             { create :group }
    let(:user)              { create :user }

    subject do
      Sunspot.commit
      get :search, query: 'Bananas'
    end

    before do
      warden.set_user user
    end

    context 'not signed in' do
      let(:user) { nil }

      it 'should have only public threads' do
        expect(subject.body).to     include(public_thread.title)
        expect(subject.body).to_not include(group_thread.title)
        expect(subject.body).to_not include(committee_thread.title)
      end
    end

    context 'not in a group' do
      it 'should have only public threads' do
        expect(subject.body).to     include(public_thread.title)
        expect(subject.body).to_not include(group_thread.title)
        expect(subject.body).to_not include(committee_thread.title)
      end
    end

    context 'as a group member' do
      before do
        create :group_membership, user: user, group: group
      end

      it 'should have public and group threads' do
        expect(subject.body).to     include(public_thread.title)
        expect(subject.body).to     include(group_thread.title)
        expect(subject.body).to_not include(committee_thread.title)
      end
    end

    context 'as a committee member' do
      before do
        create :group_membership, user: user, group: group, role: 'committee'
      end

      it 'should have public, group and committee threads' do
        expect(subject.body).to include(public_thread.title)
        expect(subject.body).to include(group_thread.title)
        expect(subject.body).to include(committee_thread.title)
      end
    end
  end

  describe 'deadlines' do
    subject            { get :deadlines, public_token: user.public_token, format: :ics }

    let(:subscription) { create :thread_subscription }
    let(:user)         { subscription.user }
    let(:thread)       { subscription.thread }
    let(:message)      { create :message, thread: thread }
    let!(:deadline)    { create :deadline_message, message: message, title: 'The AGM!', deadline: 1.day.from_now }

    it 'output the ical feed' do
      expect(subject.body).to include('The AGM!')
    end
  end
end
