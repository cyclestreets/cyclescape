# frozen_string_literal: true

require "spec_helper"

describe "User dashboards" do
  context "show" do
    context "threads" do
      include_context "signed in as a site user"

      context "with no threads" do
        it "should give guidance" do
          visit dashboard_path
          expect(page).to have_content(I18n.t(".dashboards.show.recent_threads"))
        end
      end

      context "with threads" do
        it "should list threads I've subscribed to" do
          messages = create_list(:message, 3, created_by: current_user)
          messages.each { |m| m.thread.add_subscriber(current_user) }
          expect(current_user.involved_threads.count).to be > 0
          visit dashboard_path
          messages.map(&:thread).each do |thread|
            expect(page).to have_content(thread.title)
          end
        end
      end
    end

    context "issues" do
      include_context "signed in as a site user"

      let(:issue) { create(:issue) }

      context "no locations" do
        it "should give some guidance" do
          visit dashboard_path
          expect(page).to have_content(I18n.t(".dashboards.show.add_some_locations"))
        end
      end

      context "unhelpful location" do
        before do
          # Give the current user a location that doesn't match the issue
          current_user.create_location(location: "POINT(-90 -90)")
          visit dashboard_path
        end
      end

      context "matching location" do
        before do
          # Give the current user a location that matches the issue
          current_user.create_location(location: issue.location)
          visit dashboard_path
        end

        it "should show issues in my area" do
          expect(page).to have_content(issue.title)
        end
      end
    end

    context "favourites" do
      include_context "signed in as a site user"

      context "no favourites" do
        it "should give a warning" do
          visit dashboard_path
          within("#my-favourites") do
            expect(page).to have_content(I18n.t(".dashboards.show.add_a_new_issue"))
          end
        end
      end

      context "with prioritised threads" do
        let(:thread) { create(:message_thread_with_messages) }
        let!(:favourite) { create(:user_thread_favourite, thread: thread, user: current_user) }

        it "allows changing favourite", js: true do
          visit dashboard_path
          click_on(I18n.t("dashboards.show.my_favourites"))
          expect(page).to have_content(thread.title)
          find(".fa-star").click
          expect(page).to have_content(I18n.t("message_thread.user_favourites.destroy.success"))
        end
      end
    end

    context "deadlines" do
      include_context "signed in as a site user"

      context "no deadlines" do
        it "should give a warning" do
          visit dashboard_path
          expect(page).to have_content(I18n.t(".dashboards.show.no_upcoming_deadline_threads"))
        end
      end

      context "with a deadline" do
        let!(:message) { create(:message, created_by: current_user) }
        let!(:deadline) { create(:deadline_message, message: create(:message, thread: message.thread)) }
        let!(:censored_deadline) { create(:deadline_message, message: create(:message, thread: message.thread, censored_at: Time.now.in_time_zone)) }

        it "should show the deadline" do
          deadline.thread.add_subscriber(current_user)
          visit dashboard_path
          expect(page).to have_content(deadline.title)
          deadline_localized = deadline.deadline.in_time_zone(SiteConfig.first.timezone)
          expect(page).to have_content(I18n.l(deadline_localized, format: :long_deadline).squish)
        end

        it "should not show censored deadlines" do
          censored_deadline.thread.add_subscriber(current_user)
          visit dashboard_path
          expect(page).not_to have_content(censored_deadline.title)
        end
      end
    end

    context "search", solr: true do
      include_context "signed in as a site user"

      let!(:thread) { create(:message_thread, title: "bananas") }
      let!(:issue) { create(:issue, title: "bananas also") }
      let!(:library_note) { create(:library_document, title: "more bananas") }
      let(:search_button) { I18n.t("layouts.search.search_button") }

      it "should find some bananas" do
        visit dashboard_path
        within(".main-search-box") do
          fill_in "query", with: "bananas"
          click_on search_button
        end

        expect(page).to have_content(thread.title)
        expect(page).to have_content(issue.title)
        expect(page).to have_content(library_note.title)
      end
    end
  end
end
