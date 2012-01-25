require "spec_helper"

describe "User dashboards" do
  context "show" do
    context "groups" do
      context "not in a group" do
        include_context "signed in as a site user"

        it "should have guidance about the lack of groups" do
          visit dashboard_path
          page.should have_content(I18n.t(".dashboards.show.no_user_groups"))
        end
      end

      context "in a group" do
        include_context "signed in as a group member"

        context "that has no threads" do
          it "should have guidance about the lack of threads" do
            visit dashboard_path
            page.should have_content(I18n.t(".dashboards.show.no_group_threads"))
          end
        end

        context "that has some threads" do
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
      end
    end

    context "threads" do
      include_context "signed in as a site user"

      it "should list threads I'm subscribed to"

      context "with no threads" do
        it "should give guidance" do
          visit dashboard_path
          page.should have_content(I18n.t(".dashboards.show.recent_threads"))
        end
      end

      context "with threads" do
        it "should list threads I'm involved with" do
          messages = FactoryGirl.create_list(:message, 3, created_by: current_user)
          current_user.involved_threads.count.should > 0
          visit dashboard_path
          messages.map {|m| m.thread }.each do |thread|
            page.should have_content(thread.title)
          end
        end
      end
    end

    context "issues" do
      include_context "signed in as a site user"

      let(:issue) { FactoryGirl.create(:issue) }

      context "no locations" do
        it "should give some guidance" do
          visit dashboard_path
          page.should have_content(I18n.t(".dashboards.show.add_some_locations"))
        end
      end

      context "unhelpful location" do
        before do
          # Give the current user a location that doesn't match the issue
          ul = current_user.locations.build(category: FactoryGirl.create(:location_category), location: "POINT(-90 -90)")
          ul.save
          visit dashboard_path
        end

        it "should give some more guidance" do
          page.should have_content(I18n.t(".dashboards.show.add_another_location"))
        end
      end

      context "matching location" do
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
end
