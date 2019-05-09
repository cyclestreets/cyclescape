# frozen_string_literal: true

require "spec_helper"

describe "home/show.html.haml", type: :view do
  let(:site_config) { SiteConfig.first }

  before do
    user = create :user
    assign :current_user, user
    assign :latest_threads, []
    assign :unviewed_thread_ids, []
    assign :site_config, site_config
    warden.set_user user
  end

  it "should have the intro text" do
    render

    expect(rendered).to have_content(I18n.t("home.show.introduction_html", application_name: site_config.application_name))
  end

  it "should have a report issue button" do
    render

    expect(rendered).to have_link("Create an issue")
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
