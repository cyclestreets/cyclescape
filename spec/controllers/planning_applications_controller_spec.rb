# frozen_string_literal: true

require "spec_helper"

describe PlanningApplicationsController, type: :controller do
  describe "routing" do
    it { is_expected.to route(:get, "/planning_applications/1").to(action: :show, id: 1) }
    it { is_expected.to route(:get, "/planning_applications/uid/leeds/123/uid").to(action: :show_uid, authority_param: "leeds", uid: "123/uid") }
    it { is_expected.to route(:get, "/planning_applications/search").to(action: :search) }
    it { is_expected.to route(:put, "/planning_applications/1/hide").to(action: :hide, id: 1) }
    it { is_expected.to route(:put, "/planning_applications/1/unhide").to(action: :unhide, id: 1) }
  end
end
