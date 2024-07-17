# frozen_string_literal: true

require "spec_helper"

describe IssuesController, type: :controller do
  let(:issue) { build :issue }
  let(:location_attributes) { attributes_for(:user_location_with_json_loc) }

  describe "create" do
    subject { post :create, params: { issue: issue.attributes.merge(loc_json: location_attributes[:loc_json], tags_string: "a,b") } }

    before do
      create :site_config
      warden.set_user user
    end

    context "with an approved user" do
      let(:user) { create :user, approved: true }

      it do
        expect { subject }.to change(Issue, :count).by(1)
      end
    end

    context "without an approved user" do
      let(:user) { create :user, approved: false }

      it do
        expect { subject }.not_to change(Issue, :count)
      end
    end
  end
end
