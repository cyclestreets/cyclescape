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
        fill_in "Message", with: "Damn you, woman, awake from your damnable reverie!"
        select "Public", from: "Privacy"
        click_on "Create Thread"
        page.should have_content(thread_attrs[:title])
      end

      it "should create a new private thread"
    end

    context "showing a thread" do
      before do
        visit group_thread_path(current_group, thread)
      end

      it "should show the thread title" do
        page.should have_content(thread.title)
      end

      it "should have fields to create a new message" do
        page.should have_field("Message")
      end

      it "should display all the messages in chronological order"
      it "should show who started the thread"
    end
  end
end
