require "spec_helper"

describe "Group threads" do
  let(:thread) { FactoryGirl.create(:message_thread, group: current_group) }
  let(:threads) { FactoryGirl.create_list(:message_thread_with_messages, 5, group: current_group) }

  context "as a group committee member" do
    include_context "signed in as a committee member"

    context "index page" do
      before do
        threads
        visit group_threads_path(current_group)
      end

      it "should list threads belonging to the group" do
        threads.each do |thread|
          page.should have_content(thread.title)
        end
      end
    end

    context "new thread" do
      let(:thread_attrs) { FactoryGirl.attributes_for(:message_thread) }

      before do
        visit group_threads_path(current_group)
        click_link "New Group Thread"
      end

      it "should create a new public thread" do
        fill_in "Title", with: thread_attrs[:title]
        fill_in "Body", with: "Damn you, woman, awake from your damnable reverie!"
        select "Public", from: "Privacy"
        click_on "Create Thread"
        within("h1") do
          page.should have_content(thread_attrs[:title])
        end
      end

      it "should create a new private thread"
    end
  end
end
