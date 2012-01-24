require "spec_helper"

describe "User dashboards" do
  context "show" do
    include_context "signed in as a group member"

    context "groups" do
      it "should list the latest threads from the groups I belong to" do
        current_user.groups.each do |group|
          3.times do
            # Use factory_with_trait syntax here as for some bug causes multiple
            # creates with separate trait to fail
            FactoryGirl.create(:message_thread_with_messages, group: group)
          end
        end
        visit dashboard_path
        current_user.groups.each do |group|
          group.threads.each do |thread|
            page.should have_content(thread.title)
          end
        end
      end
    end

    context "threads" do
      it "should list threads I'm subscribed to"

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
      let(:issue) { FactoryGirl.create(:issue) }

      before do
        # Give the current user a location that matches the issue
        ul = current_user.locations.build(category: FactoryGirl.create(:location_category), location: issue.location)
        ul.save
        visit dashboard_path
      end

      it "should show issues in my area" do
        page.should have_content(issue.title)
      end
    end
  end
end
