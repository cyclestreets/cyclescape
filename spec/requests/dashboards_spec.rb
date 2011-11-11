require "spec_helper"

describe "User dashboards" do
  context "show" do
    include_context "signed in as a group member"

    before do
      visit dashboard_path
    end

    context "groups" do
      it "should have all the groups I belong to" do
        current_user.groups.count.should > 0
        current_user.groups.each do |group|
          page.should have_content(group.name)
        end
      end

      it "should list the latest 3 threads from the groups I belong to" do
        current_user.groups.each do |group|
          FactoryGirl.create_list(:message_thread, 5, group: group)
          group.threads.count.should == 5
          visit dashboard_path
          group.threads.each do |thread|
            page.should have_content(thread.title)
          end
        end
      end
    end

    context "threads" do
      it "should list threads I'm subscribed to" do
        subscription = FactoryGirl.create(:thread_subscription, user: current_user)
        current_user.subscribed_threads.count.should > 0
        visit dashboard_path
        current_user.subscribed_threads.each do |thread|
          page.should have_content(thread.title)
        end
      end

      it "should list threads I'm involved with" do
        messages = FactoryGirl.create_list(:message, 3, created_by: current_user)
        current_user.involved_threads.count.should > 0
        visit dashboard_path
        messages.map {|m| m.thread }.each do |thread|
          page.should have_content(thread.title)
        end
      end
    end

    context "issues" do
      it "should show issues in my area"
    end
  end
end
