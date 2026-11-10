# frozen_string_literal: true

require "spec_helper"

describe Group::MessageThreadsController do
  render_views

  let(:group) { create(:group) }

  before { warden.set_user create(:user) }

  it "renders the intro for the view in a frame request" do
    request.headers["Turbo-Frame"] = "threads_frame"
    get :index, params: { group_id: group.id, view: "general" }

    expect(response.body).to include(I18n.t("group.message_threads.index.general_threads_description"))
    expect(response.body).not_to include("<html")
  end
end
