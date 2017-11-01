require 'spec_helper'

describe Group::ProfilesController, type: :controller do
  let(:resource) { create :group_profile }
  let(:group) { resource.group }
  let(:user) { create(:user).tap{ |usr| create(:group_membership, :committee, user: usr, group: group) } }

  before do
    warden.set_user user
  end

  describe '#update' do
    it 'has index' do
      put :update, group_id: group.id, group_profile: { new_user_email: nil }
      expect(response.status).to eq(200)
    end
  end
end
