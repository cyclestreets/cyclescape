require 'spec_helper'

describe MessagesController, type: :controller do
  describe 'approve' do
    let(:message)          { create(:message, :possible_spam, thread: message_thread) }
    let(:message_thread)   { create(:message_thread, :belongs_to_group) }
    let(:group)            { message_thread.group }
    let(:committee_member) { create(:user).tap{ |usr| create(:group_membership, :committee, user: usr, group: group) } }
    let(:other_user)       { create(:group_membership, :committee).user }

    before do
      warden.set_user user_type
    end

    subject { put :approve, id: message.id, thread_id: message_thread.id, format: :js }

    context 'for a committee member' do
      let!(:req)      { stub_request(:post, /rest\.akismet\.com\/1\.1\/submit-ham/).to_return(status: 200) }
      let(:user_type) { committee_member }

      it { expect(subject.status).to eq(200) }
      it { subject; expect(req).to have_been_made }
    end

    context 'for a non committee member' do
      let(:user_type) { other_user }
      it { expect(subject.status).to eq(401) }
    end
  end
end
