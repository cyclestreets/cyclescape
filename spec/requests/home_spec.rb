require "spec_helper"

describe "Home page" do
  it "should have the intro text" do
    visit home_path
    page.should have_content(I18n.t("home.show.introduction_html"))
  end

  it "should have a report issue button" do
    visit home_path
    page.should have_link("Report an issue")
  end

  context "discussions" do
    let!(:threads) { FactoryGirl.create_list(:message_thread_with_messages, 7) }

    it "should list 6 discussions" do
      visit home_path
      threads[1..6].each do |thread|
        page.should have_link(thread.title)
      end
      page.should_not have_content(threads[0].title)
    end

    it "should be ordered by most recent activity first" do
      visit home_path
      within("ul.thread-list li:first") do
        page.should have_content(threads.last.title)
      end
      within("ul.thread-list li:last") do
        page.should have_content(threads[1].title)
      end
    end

    it "should not contain private discussions" do
      private_thread = FactoryGirl.create(:group_private_message_thread)
      visit home_path
      page.should_not have_content(private_thread.title)
    end
  end
end
