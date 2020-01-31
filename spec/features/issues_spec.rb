# encoding: UTF-8
# frozen_string_literal: true

require "spec_helper"

describe "Issues" do
  # NOTE: most of the 'new' context is covered in ./issues_with_notifications_spec.rb
  context "new" do
    let!(:membership) { create(:chris_at_quahogcc, group: group) }
    let!(:password) { attributes_for(:chris)[:password] }
    let(:user) { membership.user }
    let(:group_profile) { create(:quahogcc_group_profile) }
    let(:group) { group_profile.group }
    let(:host) { "http://#{group.subdomain}.localhost" }

    it "use group location sets the location and updates the map", js: true do
      visit "#{host}#{new_user_session_path}"
      fill_in "Email", with: user.email
      fill_in "Password", with: password
      click_button "Sign in"
      expect(page).to have_content("Sign out")

      visit "#{host}#{new_issue_path}"

      click_on I18n.t("issues.form.use_groups_location")
      expect(find("#issue_loc_json", visible: false).value).to include group_profile.loc_json
      expect(all(".leaflet-marker-icon").size).to eq 22
    end
  end

  context "show" do
    let!(:issue) { create(:issue) }

    context "as a public user" do
      before do
        visit issue_path(issue)
      end

      it "should show the issue title" do
        expect(page).to have_content(issue.title)
      end

      it "should show the description" do
        expect(page).to have_content(issue.description)
      end

      it "should set the page title" do
        expect(page).to have_title(issue.title)
      end

      context "with photo" do
        let!(:issue) { create(:issue, :with_photo) }

        it "should show the photo with a link to a larger version" do
          within("section.photos") do
            find("a").click
          end
          expect(find(".photo img")[:alt]).to include(issue.title)
        end

        it "should have the photo link" do
          # restating the above test, in order to prove the negative version, next.
          expect(page.source).to include(issue_photo_path(issue))
        end
      end

      it "should not show you the photo link (without a photo)" do
        expect(page.source).not_to include(issue_photo_path(issue))
      end

      it "should raise a 404 exception if the photo path is accessed on an issue without a photo" do
        expect do
          visit issue_photo_path(issue)
        end.to raise_error(ActionController::RoutingError)
      end

      it "should not show you an edit tags link" do
        expect(page).not_to have_content(I18n.t(".shared.tags.panel.edit_tags"))
      end

      it "should show you a twitter link" do
        # Note that the twitter link is an unobtrusive link, which is then massively mangled by JS
        # So this tests the unobtrustive version, not the iframe that you'll end up with in the browser.
        expect(page).to have_link("Tweet")
        expect(find_link("Tweet")["data-via"]).to eql("cyclescape")
        expect(find_link("Tweet")["data-text"]).to eql(issue.title)
      end
    end

    context "with threads" do
      context "as a public user" do
        let!(:issue) { create(:issue) }
        let(:other_group) { create(:group) }
        let!(:public_thread) { create(:message_thread_with_messages, issue: issue) }
        let!(:private_thread) { create(:message_thread_with_messages, :private, group: other_group, issue: issue) }

        it "should link to the public thread" do
          visit issue_path(issue)
          expect(page).to have_link(public_thread.title, href: thread_path(public_thread))
        end

        it "should censor the private thread title" do
          visit issue_path(issue)
          expect(page).to have_content("[Private thread]")
        end
      end
    end

    context "as a site user" do
      include_context "signed in as a site user"

      before do
        visit issue_path(issue)
      end

      it "should have a link to create a new public thread" do
        expect(page).to have_link("Discuss")
      end
    end

    context "as a group member" do
      include_context "signed in as a group member"

      before do
        visit issue_path(issue)
      end

      it "should have a link to create a new public thread" do
        expect(page).to have_link("Discuss")
      end
    end

    context "tags", as: :site_user do
      let!(:issue) { create(:issue, :with_tags) }

      before do
        visit issue_path(issue)
      end

      it "should be shown" do
        expect(page).to have_link(issue.tags.first.name)
        expect(page).to have_link(issue.tags.second.name)
      end

      it "should be editable" do
        # This form is initially hidden
        within("form.edit-tags") do
          fill_in "Tags", with: "pothole dangerous"
          click_on I18n.t(".formtastic.actions.update_tags")
        end
        # Page submission is AJAX and returns json
        expect(page.source).to have_content("pothole")
        expect(page.source).to have_content("dangerous")
      end
    end
  end

  describe "index" do
    context "as a public user" do
      let!(:issues) { create_list(:issue, 3) }
      let(:voter) { create(:user) }

      it "should have the issue titles" do
        visit issues_path
        issues.each do |issue|
          expect(page).to have_content(issue.title)
        end
      end

      it "should have the issue descriptions" do
        visit issues_path
        issues.each do |issue|
          expect(page).to have_content(issue.description)
        end
      end

      it "should list issues by most recent first" do
        visit issues_path
        issues.reverse.each_with_index do |issue, i|
          within("ul.issue-list > li:nth-of-type(#{i + 1})") do
            expect(page).to have_content(issue.title)
          end
        end
      end

      it "should show popular upvoted issues" do
        voter.vote_for(issues[0])
        voter.vote_against(issues[1])

        visit issues_path
        within("#popular-pane") do
          expect(page).to have_content(issues[0].title)
          expect(page).not_to have_content(issues[1].title)
          expect(page).not_to have_content(issues[2].title)
        end
      end
    end
  end

  context "search", solr: true do
    include_context "signed in as a site user"
    let!(:issue) { create(:issue, :with_tags) }
    # main search box doesn't have any I18n'd content, just a js-based placeholder.
    # use the id of the field instead.
    let(:search_field) { "query" }
    let(:search_button) { I18n.t("layouts.search.search_button") }

    before do
      visit issues_path
    end

    it "should return results for a title search" do
      within(".main-search-box") do
        fill_in search_field, with: issue.title
        click_on search_button
      end

      expect(page).to have_content(issue.title)
    end

    it "should return results for a description search" do
      within(".main-search-box") do
        fill_in search_field, with: "Whose leg do you have to hump"
        click_on search_button
      end

      expect(page).to have_content(issue.title)
    end

    it "should return results for a tag search" do
      within(".main-search-box") do
        fill_in search_field, with: issue.tags.first.name
        click_on search_button
      end

      expect(page).to have_content(issue.title)
    end

    it "should return no results for gibberish" do
      within(".main-search-box") do
        fill_in search_field, with: "abcdefgh12345"
        click_on search_button
      end

      expect(page).to have_content("No results found")
    end

    it "should not return deleted issues" do
      within(".main-search-box") do
        fill_in search_field, with: issue.title
        issue.destroy
        click_on search_button
      end

      expect(page).to have_content("No results found")
    end
  end

  context "delete" do
    let!(:issue) { create(:issue) }
    let(:delete_text) { "Delete this issue" }

    context "as a site user" do
      include_context "signed in as a site user"

      it "should not show you a delete link" do
        visit issue_path(issue)
        expect(page).not_to have_content(delete_text)
      end

      it "should not let you delete the page" do
        visit issue_path(issue)
        # Use the slightly-unofficial capybara mechanism to simulate a delete
        page.driver.delete issue_path(issue)
        expect(page).to have_content("You are not authorised to access that page.")
      end
    end

    context "as an admin" do
      include_context "signed in as admin"

      it "should show you a delete link" do
        visit issue_path(issue)
        expect(page).to have_content(delete_text)
      end

      it "should let you delete the issue" do
        visit issue_path(issue)
        click_on delete_text
        expect(page).to have_content("Issue deleted")
        expect(page).not_to have_content(issue.title)
      end
    end
  end

  context "editing" do
    let(:edit_text) { "Edit this issue" }

    context "as an admin" do
      include_context "signed in as admin"

      let(:issue) { create(:issue) }

      it "should show you an edit link" do
        visit issue_path(issue)
        expect(page).to have_content(edit_text)
      end

      it "should let you edit the issue" do
        visit issue_path(issue)
        click_on edit_text
        expect(page).to have_content("Edit Issue")
        fill_in "Title", with: "Something New"
        click_on I18n.t("formtastic.actions.issue.update")
        issue.reload
        expect(current_path).to eq(issue_path(issue))
        expect(page).to have_content("Something New")
      end
    end

    context "as the creator" do
      include_context "signed in as a site user"

      context "recent" do
        let(:issue) { create(:issue, created_by: current_user) }

        it "should show you an edit link" do
          visit issue_path(issue)
          expect(page).to have_content(edit_text)
        end
      end
    end

    context "as another user" do
      include_context "signed in as a site user"
      let(:issue) { create(:issue) }

      it "should not show you an edit link" do
        visit issue_path(issue)
        expect(page).not_to have_content(edit_text)
      end
    end
  end

  context "voting" do
    let(:issue) { create(:issue) }

    context "as a visitor" do
      before do
        create(:user).vote_for(issue)
        visit issue_path(issue)
      end

      it "should show the vote count", js: true do
        within(".votes") do
          expect(page).to have_content("1")
        end
      end

      it "should not allow you to vote" do
        expect(page).to have_content("Please sign in to vote")
        find(:css, ".vote-count.unvoted").click
        expect(page).to have_content("You need to sign in or sign up before continuing.")
        expect(issue.votes_count).to eql(1)
      end
    end

    shared_examples "vote and cancel your vote" do
      it "vote and cancel", js: true do
        within ".tally" do
          expect(page).to have_content("0")
          expect(page).to_not have_content("1")
        end

        find(:css, ".vote-count").click

        within ".tally" do
          expect(page).to have_content("1")
          expect(page).to_not have_content("0")
        end

        find(:css, ".vote-count").click

        within ".tally" do
          expect(page).to have_content("0")
          expect(page).to_not have_content("1")
        end
      end
    end

    context "as a site user" do
      include_context "signed in as a site user"

      context "for a specific issue" do
        let!(:resource) { issue }
        before { visit issue_path(issue) }

        include_examples "vote and cancel your vote"
      end

      context "for the issues index" do
        let!(:resource) { issue }
        before { visit issues_path }

        include_examples "vote and cancel your vote"
      end

      context "for the issues index" do
        let(:thread) { message.thread }
        let(:message) { create :message }
        let!(:resource) { message }

        before { visit thread_path(thread) }

        include_examples "vote and cancel your vote"
      end
    end
  end

  context "geojson" do
    context "issue" do
      let(:issue) { create(:issue) }

      before do
        visit geometry_issue_path(issue, format: :json)
      end

      it "should return a thumbnail attribute" do
        expect(page).to have_content("thumbnail")
      end
    end

    context "all issues" do
      let!(:issue) { create(:issue) }

      before do
        visit all_geometries_issues_path(format: :json)
      end

      it "should return various attributes" do
        expect(page).to have_content("thumbnail")
        expect(page).to have_content("created_by_url")
      end
    end
  end
end
