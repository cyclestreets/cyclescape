require 'spec_helper'

describe GroupsController, type: :controller do

  describe 'routing' do
    it { is_expected.to route(:get, 'http://subdomain.example.com').to(action: :show) }
  end

  describe 'show' do
    let(:group)            { create :group }
    let(:committee_member) { create(:user).tap{ |usr| create(:group_membership, :committee, user: usr, group: group) } }

    before do
      warden.set_user committee_member
    end

    subject { get :show, id: group.id }

    context 'for a committee member' do
      it { expect(subject.status).to eq(200) }
    end
  end
end

