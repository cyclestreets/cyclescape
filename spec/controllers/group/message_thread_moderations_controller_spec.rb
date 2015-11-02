require 'spec_helper'

describe Group::MessageThreadModerationsController, type: :controller do
  let(:message_thread)   { create(:message_thread, :belongs_to_group, :with_messages, :possible_spam) }
  let(:group)            { message_thread.group }
  let(:committee_member) { create(:user).tap{ |usr| create(:group_membership, :committee, user: usr, group: group) } }
  let(:other_user)       { create(:group_membership, :committee).user }

  describe 'index' do
    before do
      warden.set_user user_type
    end

    subject { get :index, group_id: group.to_param }

    context 'for a committee member' do
      let(:user_type) { committee_member }
      it { expect(subject.status).to eq(200) }
    end

    context 'for a non committee member' do
      let(:user_type) { other_user }
      it { expect(subject.status).to eq(401) }
    end
  end
end
