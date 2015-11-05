require 'spec_helper'

describe DashboardsController, type: :controller do

  describe 'search', solr: true do
    let!(:public_thread)    { create(:message_thread, title: 'Public Bananas Thread') }
    let!(:group_thread)     { create(:message_thread, :private, group: group, title: 'Group Bananas Thread') }
    let!(:committee_thread) { create(:message_thread, :committee, group: group, title: 'Committee Bananas Thread') }
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
end
