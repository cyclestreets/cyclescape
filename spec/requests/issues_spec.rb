# encoding: UTF-8
require "spec_helper"

describe "Issues" do
  let(:issue_values) { FactoryGirl.attributes_for(:issue_with_json_loc) }

  context "new" do
    context "as site member" do
      include_context "signed in as a site user"

      before do
        visit new_issue_path
      end

      it "should create a new issue" do
        fill_in "Title", with: issue_values[:title]
        attach_file "Add a photo", test_photo_path
        fill_in "Tag your issue", with: "parking"
        fill_in "Write a description", with: issue_values[:description]
        # Note hidden map field
        find("#issue_loc_json").set(issue_values[:loc_json])
        click_on "Send Report"
        within("#content header") do
          page.should have_content(issue_values[:title])
        end
        page.should have_content("parking")
        page.should have_content(current_user.name)
      end

      it "must not barf on duplicate tags" do
        fill_in "Title", with: issue_values[:title]
        fill_in "Write a description", with: issue_values[:description]
        find("#issue_loc_json").set(issue_values[:loc_json])

        fill_in "Tag your issue", with: "parking parking"

        click_on "Send Report"
        within("#content header") do
          page.should have_content(issue_values[:title])
        end
      end

      it "must not barf on nasty tags" do
        fill_in "Title", with: issue_values[:title]
        fill_in "Write a description", with: issue_values[:description]
        find("#issue_loc_json").set(issue_values[:loc_json])

        fill_in "Tag your issue", with: "equals = êquals"

        click_on "Send Report"
        within("#content header") do
          page.should have_content(issue_values[:title])
        end
      end
    end
  end

  context "show" do
    let!(:issue) { FactoryGirl.create(:issue) }

    context "as a public user" do
      before do
        visit issue_path(issue)
      end

      it "should show the issue title" do
        page.should have_content(issue.title)
      end

      it "should show the description" do
        page.should have_content(issue.description)
      end

      it "should set the page title" do
        within "title" do
          page.should have_content(issue.title)
        end
      end

      it "should show the location"

      context "with photo" do
        let!(:issue) { FactoryGirl.create(:issue, :with_photo) }

        it "should show the photo" do
          page.should have_selector("img.issue-photo")
        end

        it "should show the photo with a link to a larger version" do
          within("section.photos") do
            find("a").click
          end
          find(".photo img")[:alt].should include(issue.title)
        end

        it "should have the photo link" do
          # restating the above test, in order to prove the negative version, next.
          page.source.should include(issue_photo_path(issue))
        end
      end

      it "should not show you the photo link (without a photo)" do
        page.source.should_not include(issue_photo_path(issue))
      end

      it "should raise a 404 exception if the photo path is accessed on an issue without a photo" do
        lambda do
          visit issue_photo_path(issue)
        end.should raise_error(ActionController::RoutingError)
      end

      it "should not show you an edit tags link" do
        page.should_not have_content(I18n.t(".shared.tags.panel.edit_tags"))
      end

      it "should show you a twitter link" do
        # Note that the twitter link is an unobtrusive link, which is then massively mangled by JS
        # So this tests the unobtrustive version, not the iframe that you'll end up with in the browser.
        page.should have_link("Tweet")
        find_link("Tweet")["data-via"].should eql("cyclescape")
        find_link("Tweet")["data-text"].should eql(issue.title)
      end
    end

    context "with threads" do
      context "as a public user" do
        let!(:issue) { FactoryGirl.create(:issue) }
        let(:other_group) { FactoryGirl.create(:group) }
        let!(:public_thread) { FactoryGirl.create(:message_thread_with_messages, issue: issue) }
        let!(:private_thread) { FactoryGirl.create(:message_thread_with_messages, :private, group: other_group, issue: issue) }

        it "should link to the public thread" do
          visit issue_path(issue)
          page.should have_link(public_thread.title, href: thread_path(public_thread))
        end

        it "should censor the private thread title" do
          visit issue_path(issue)
          page.should have_content("[Private thread]")
        end
      end
    end

    context "as a site user" do
      include_context "signed in as a site user"

      before do
        visit issue_path(issue)
      end

      it "should have a link to create a new public thread" do
        page.should have_link("Discuss")
      end
    end

    context "as a group member" do
      include_context "signed in as a group member"

      before do
        visit issue_path(issue)
      end

      it "should have a link to create a new public thread" do
        page.should have_link("Discuss")
      end
    end

    context "tags", as: :site_user do
      let!(:issue) { FactoryGirl.create(:issue, :with_tags) }

      before do
        visit issue_path(issue)
      end

      it "should be shown" do
        page.should have_link(issue.tags.first.name)
        page.should have_link(issue.tags.second.name)
      end

      it "should be editable" do
        # This form is initially hidden
        within("form.edit-tags") do
          fill_in "Tags", with: "pothole dangerous"
          click_on I18n.t(".formtastic.actions.issue.update_tags")
        end
        # Page submission is AJAX and returns json
        page.source.should have_content("pothole")
        page.source.should have_content("dangerous")
      end
    end
  end

  describe "index" do
    context "as a public user" do
      let!(:issues) { FactoryGirl.create_list(:issue, 3) }
      let(:voter) { FactoryGirl.create(:user) }

      it "should have the issue titles" do
        visit issues_path
        issues.each do |issue|
          page.should have_content(issue.title)
        end
      end

      it "should have the issue descriptions" do
        visit issues_path
        issues.each do |issue|
          page.should have_content(issue.description)
        end
      end

      it "should list issues by most recent first" do
        visit issues_path
        issues.reverse.each_with_index do |issue, i|
          within("ul.issue-list > li:nth-of-type(#{i + 1})") do
            page.should have_content(issue.title)
          end
        end
      end

      it "should show popular upvoted issues" do
        voter.vote_for(issues[0])
        voter.vote_against(issues[1])

        visit issues_path
        within("#popular-pane") do
          page.should have_content(issues[0].title)
          page.should_not have_content(issues[1].title)
          page.should_not have_content(issues[2].title)
        end
      end
    end
  end

  context "search" do
    include_context "signed in as a site user"
    let(:issue) { FactoryGirl.create(:issue, :with_tags) }
    # main search box doesn't have any I18n'd content, just a js-based placeholder.
    # use the id of the field instead.
    let(:search_field) { "query" }
    let(:search_button) { I18n.t("layouts.search.search_button") }

    before do
      visit issues_path
    end

    it "should return results for a title search" do
      within('.main-search-box') do
        fill_in search_field, with: issue.title
        click_on search_button
      end

      page.should have_content(issue.title)
    end

    it "should return results for a description search" do
      within('.main-search-box') do
        fill_in search_field, with: issue.description
        click_on search_button
      end

      page.should have_content(issue.title)
    end

    it "should return results for a tag search" do
      within('.main-search-box') do
        fill_in search_field, with: issue.tags.first.name
        click_on search_button
      end

      page.should have_content(issue.title)
    end

    it "should return no results for gibberish" do
      within('.main-search-box') do
        fill_in search_field, with: "abcdefgh12345"
        click_on search_button
      end

      page.should have_content("No results found")
    end

    it "should not return deleted issues" do
      within('.main-search-box') do
        fill_in search_field, with: issue.title
        issue.destroy
        click_on search_button
      end

      page.should have_content("No results found")
    end
  end

  context "delete" do
    let!(:issue) { FactoryGirl.create(:issue) }
    let(:delete_text) { "Delete this issue" }

    context "as a site user" do
      include_context "signed in as a site user"

      it "should not show you a delete link" do
        visit issue_path(issue)
        page.should_not have_content(delete_text)
      end

      it "should not let you delete the page" do
        visit issue_path(issue)
        # Use the slightly-unofficial capybara mechanism to simulate a delete
        page.driver.delete issue_path(issue)
        page.should have_content("You are not authorised to access that page.")
      end
    end

    context "as an admin" do
      include_context "signed in as admin"

      it "should show you a delete link" do
        visit issue_path(issue)
        page.should have_content(delete_text)
      end

      it "should let you delete the issue" do
        visit issue_path(issue)
        click_on delete_text
        page.should have_content("Issue deleted")
        page.should_not have_content(issue.title)
      end
    end
  end

  context "editing" do
    let(:edit_text) { "Edit this issue" }

    context "as an admin" do
      include_context "signed in as admin"

      let(:issue) { FactoryGirl.create(:issue) }

      it "should show you an edit link" do
        visit issue_path(issue)
        page.should have_content(edit_text)
      end

      it "should let you edit the issue" do
        visit issue_path(issue)
        click_on edit_text
        page.should have_content("Edit Issue")
        fill_in "Title", with: "Something New"
        click_on "Save"
        current_path.should == issue_path(issue)
        page.should have_content("Something New")
      end
    end

    context "as the creator" do
      include_context "signed in as a site user"

      context "recent" do
        let(:issue) { FactoryGirl.create(:issue, created_by: current_user) }

        it "should show you an edit link" do
          visit issue_path(issue)
          page.should have_content(edit_text)
        end
      end

      context "long ago" do
        let(:issue) { FactoryGirl.create(:issue, created_by: current_user, created_at: 2.days.ago) }

        it "should not show you an edit link" do
          visit issue_path(issue)
          page.should_not have_content(edit_text)
        end
      end
    end

    context "as another user" do
      include_context "signed in as a site user"
      let(:issue) { FactoryGirl.create(:issue) }

      it "should not show you an edit link" do
        visit issue_path(issue)
        page.should_not have_content(edit_text)
      end
    end
  end

  context "voting" do
    let(:issue) { FactoryGirl.create(:issue) }
    let(:meg) { FactoryGirl.create(:meg) }

    before do
      meg.vote_for(issue)
    end

    def within_voting_panel(&block)
      within(".voting", &block)
    end

    context "as a visitor" do
      before do
        visit issue_path(issue)
      end

      it "should show the vote count" do
        within_voting_panel do
          page.should have_content("1")
        end
      end

      it "should not allow you to vote" do
        click_on "Vote Up"
        page.should have_content("You need to sign in or sign up before continuing.")
        issue.votes_count.should eql(1)
      end

      it "should have a message saying they need to sign in" do
        page.should have_content("Please sign in to vote")
      end
    end

    context "as a site user" do
      include_context "signed in as a site user"
      before do
        visit issue_path(issue)
      end

      it "should allow you to vote up" do
        click_on "Vote Up"
        page.should have_content("You have voted up this issue")
        within_voting_panel do
          page.should have_content("2")
        end
      end

      it "should allow you to vote down" do
        click_on "Vote Down"
        page.should have_content("You have voted down this issue")
        within_voting_panel do
          page.should have_content("0")
        end
      end

      it "shouldn't count repeated votes" do
        click_on "Vote Up"
        page.should_not have_content("Vote Up")
      end

      it "should allow you to change your vote" do
        click_on "Vote Up"
        click_on "Vote Down"
        within_voting_panel do
          page.should have_content("0")
        end
      end

      it "should allow you to cancel your vote" do
        within_voting_panel do
          page.should have_content("1")
          click_on "Vote Up"
        end
        # Keep these blocks seperate otherwise first page reference
        # is retained
        within_voting_panel do
          click_on "Cancel"
        end
        page.should have_content("Your vote has been cleared")
        within_voting_panel do
          page.should have_content("1")
        end
      end
    end
  end

  context "geojson" do
    context "issue" do
      let(:issue) { FactoryGirl.create(:issue) }

      before do
        visit geometry_issue_path(issue, format: :json)
      end

      it  "should return a thumbnail attribute" do
        page.should have_content("thumbnail")
      end
    end

    context "all issues" do
      let!(:issue) { FactoryGirl.create(:issue) }

      before do
        visit all_geometries_issues_path(format: :json)
      end

      it "should return various attributes" do
        page.should have_content("thumbnail")
        page.should have_content("created_by_url")
      end
    end
  end
end
