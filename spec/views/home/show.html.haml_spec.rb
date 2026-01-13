# frozen_string_literal: true

require "spec_helper"

describe "home/show.html.haml", type: :view do
  let(:site_config) { SiteConfig.first }

  before do
    user = create :user
    assign :current_user, user
    assign :tags, []
    assign :site_config, site_config
    warden.set_user user
    allow(view).to receive(:policy) do |record|
      Pundit.policy(user, record)
    end
  end

  context "discussions" do
    let(:threads) { create_list(:message_thread_with_messages, 3) }

    before do
      assign :latest_threads, ThreadListDecorator.decorate_collection(threads)
    end

    it "should be ordered by most recent activity first" do
      render

      within("ul.thread-list li:first") do
        expect(rendered).to have_content(threads.last.title)
      end
      within("ul.thread-list li:last") do
        expect(rendered).to have_content(threads.first.title)
      end
    end

    it "should not contain private discussions" do
      private_thread = create(:group_private_message_thread)
      render
      expect(rendered).not_to have_content(private_thread.title)
    end
  end
end
