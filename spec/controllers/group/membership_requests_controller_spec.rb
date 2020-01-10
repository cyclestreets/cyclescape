# frozen_string_literal: true

require "spec_helper"

describe Group::MembershipRequestsController, type: :controller do
  let(:membership_request)   { create(:pending_gmr) }
  let(:group)                { membership_request.group }
  let(:committee_membership) { create(:group_membership, group: group, role: "committee") }
  let(:committee_member)     { committee_membership.user }

  describe "routing" do
    it { is_expected.to route(:get, "groups/1/membership_requests").to(action: :index, group_id: 1) }
  end

  describe "pages" do
    before do
      warden.set_user committee_member
    end

    describe "#reject" do
      it "sends a notification with rejection_message" do
        post :reject, params: {
          group_id: group.id, id: membership_request.id, group_membership_request: { rejection_message: "No thanks" }
        }
        expect(membership_request.reload).to be_rejected
        expect(all_emails.last.body.decoded).to match(/Your request to join.*has not been approved.*No thanks/m)
      end

      it "sends no notification without a rejection_message" do
        post :reject, params: {
          group_id: group.id, id: membership_request.id, group_membership_request: { rejection_message: "" }
        }
        expect(membership_request.reload).to be_rejected
        expect(all_emails).to be_blank
      end
    end

    context "with confirmed request" do
      before do
        membership_request.actioned_by = committee_member
        membership_request.confirm!
      end

      it "#index" do
        get :index, params: { group_id: group.id }
        expect(response.status).to eq(200)
      end

      it "#review" do
        get :review, params: { group_id: group.id, id: membership_request.id }
        expect(response.status).to eq(200)
      end
    end
  end
end
