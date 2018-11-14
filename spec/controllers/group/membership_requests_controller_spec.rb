require 'spec_helper'

describe Group::MembershipRequestsController, type: :controller do
  let(:membership_request)   { create(:pending_gmr) }
  let(:group)                { membership_request.group }
  let(:committee_membership) { create(:group_membership, group: group, role: 'committee') }
  let(:committee_member)     { committee_membership.user }

  describe 'routing' do
    it { is_expected.to route(:get, 'groups/1/membership_requests').to(action: :index, group_id: 1) }
  end

  describe 'pages' do
    before do
      membership_request.actioned_by = committee_member
      membership_request.confirm!
      warden.set_user committee_member
    end

    it 'has index' do
      get :index, params: { group_id: group.id }
      expect(response.status).to eq(200)
    end
  end
end
