# frozen_string_literal: true

require "spec_helper"

describe "Message threads", type: :feature do
  let(:thread) { create(:message_thread_with_messages, :with_tags) }
  let!(:threads) { create_list(:message_thread_with_messages, 3) }
  let(:censor_message) { "Censor this message" }
  let(:delete_thread) { "Delete this thread" }
  let(:edit_thread) { "Edit this thread" }

  context "as a public user" do
    context "index" do
      before do
        threads
        visit threads_path
      end

      it "should list public message threads" do
        threads.each do |thread|
          expect(page).to have_content(thread.title)
        end
      end
    end

    context "show" do
      let(:thread) { threads.first }
      let(:messages) { thread.messages }

      before do
        threads
        visit threads_path
        click_link thread.title
      end

      it "should show the thread title" do
        within(".thread h1") do
          expect(page).to have_content(thread.title)
        end
      end

      it "should show messages on a public thread" do
        messages.each do |message|
          expect(page).to have_content(message.body)
          expect(page).to have_content(message.created_by.name)
        end
      end

      it "should not show a link to edit tags" do
        expect(page).not_to have_content(I18n.t(".shared.tags.panel.edit_tags"))
      end

      it "should set the page title" do
        expect(page).to have_title(thread.title)
      end

      it "should display a notice saying the user must sign in to post" do
        expect(page).to have_content("Please sign in to post a message")
        expect(page).not_to have_selector("#message_body")
      end
    end

    context "deleted issue" do
      let(:thread_with_issue) { create(:issue_message_thread) }
      let(:issue) { thread_with_issue.issue }

      before do
        thread_with_issue.issue.destroy
        visit thread_path(thread_with_issue)
      end

      it "should not show the issue" do
        expect(page).not_to have_content(issue.title)
      end

      it "should still show the thread" do
        expect(page).to have_content(thread_with_issue.title)
      end
    end
  end

  context "as a site user" do
    include_context "signed in as a site user"

    context "index" do
      before do
        threads
      end

      it "should list all public message threads" do
        visit threads_path
        threads.each do |thread|
          expect(page).to have_content(thread.title)
        end
      end

      it "should indicate which threads I follow" do
        first = threads.first
        first.add_subscriber(current_user)
        visit threads_path
        within("li[data-thread-id='#{first.id}']") do
          expect(page).to have_content("Following")
        end
      end

      it "should link to the issue" do
        issue_thread = create(:issue_message_thread, :with_messages)
        visit threads_path
        expect(page).to have_link(issue_thread.issue.title)
      end
    end

    context "show" do
      before do
        visit thread_path(thread)
      end

      context "messages" do
        it "should show all messages" do
          thread.messages.each do |message|
            expect(page).to have_content(message.body)
          end
        end

        it "should be able to post a new message" do
          fill_in "Message", with: "Testing a new message!", match: :first
          click_on "Post Message"
          expect(page).to have_content("Testing a new message!")
        end

        it "should allow messages with links", js: true do
          within(".new-message") do
            tinymce_fill_in with: 'Testing autolink <a href="http://example.com">http://example.com</a>'
            click_on "Post Message"
          end
          expect(page).to have_link("http://example.com")
        end

        it "should not be disabled as it is for guests" do
          expect(page).to have_no_content("Please sign in to post a message")
        end
      end

      context "subscribers" do
        it "should show the names of subscribers" do
          click_on "Follow this thread"
          within(".subscribers") do
            expect(page).to have_content(current_user.name)
          end
        end
      end

      context "censoring" do
        it "should not have a censor link" do
          expect(page).not_to have_content(censor_message)
        end

        it "should not let you censor a message" do
          page.driver.put censor_thread_message_path(thread, thread.messages[0])
          expect(page).to have_content(I18n.t("shared.permission_denied.login"))
        end
      end

      context "tags" do
        it "should show the linked tags" do
          thread.tags.each do |tag|
            expect(page).to have_content(tag.name)
          end
        end

        it "should edit the tags" do
          # This form is initially hidden
          within("form.edit-tags") do
            fill_in "Tags", with: "bike wheels"
            click_on I18n.t(".formtastic.actions.update_tags")
          end
          # Page submission is AJAX and returns json
          expect(page.source).to have_content("bike")
          expect(page.source).to have_content("wheels")
          # Check the response has information for the library panel.
          expect(JSON.parse(page.source)["librarypanel"]).not_to be_nil
        end
      end
    end

    context "delete" do
      context "as a normal user" do
        before do
          visit thread_path(thread)
        end

        it "should not show a delete link" do
          expect(page).not_to have_content(delete_thread)
        end

        it "should not let you delete a thread" do
          page.driver.delete thread_path(thread)
          expect(page).to have_content(I18n.t("shared.permission_denied.login"))
        end
      end

      context "as a committee member" do
        before do
          membership = create :group_membership
          thread.update!(group: membership.group, created_by: membership.user)
          current_user.memberships.create!(group: thread.group, role: "committee")
          visit thread_path(thread)
        end

        it "should show a delete link and thread is delete-able" do
          expect(page).to have_content(delete_thread)

          page.driver.delete thread_path(thread)
          expect(page).to_not have_content(I18n.t("shared.permission_denied.login"))
          expect(page.driver.response.location).to include(threads_path)
        end
      end
    end

    context "edit" do
      context "when logged in as thread creator member" do
        before do
          thread.update!(created_by: current_user)
        end

        it "should show an edit link (but no delete link)" do
          visit thread_path(thread)
          expect(page).to have_content(edit_thread)
          expect(page).not_to have_content(delete_thread)
        end

        it "should let you edit a thread" do
          visit edit_thread_path(thread)
          expect(page).to have_content("Edit thread")
          fill_in I18n.t("activerecord.attributes.message_thread.title"), with: "New better title"
          expect(page).to have_no_select("Privacy")
          expect(page).to have_no_select("Owned by")
          click_on "Save"
          expect(page).to have_content("Thread updated")
          expect(page).to have_content("New better title")
        end
      end

      context "when logged in as another member" do
        it "should not show an edit link" do
          visit thread_path(thread)
          expect(page).not_to have_content(edit_thread)
        end

        it "should not let you edit a thread" do
          visit edit_thread_path(thread)
          expect(page).to have_content(I18n.t("shared.permission_denied.login"))
          expect(page).to have_no_content("Edit thread")
        end
      end
    end
  end

  context "as an admin user" do
    include_context "signed in as admin"

    context "message censoring" do
      before do
        visit thread_path(thread)
      end

      it "should provide a censor link" do
        expect(page).to have_content(censor_message)
      end

      it "should let you censor a message" do
        click_on censor_message, match: :first
        expect(page).to have_content("Message censored")
        expect(page).to have_content("This message has been removed")
      end
    end

    context "thread deletion" do
      before do
        visit thread_path(thread)
      end

      it "should let you delete the thread" do
        click_on delete_thread
        expect(page).to have_content("Thread deleted")
        expect(page).not_to have_content(thread.title)
      end
    end

    context "thread editing" do
      before do
        visit thread_path(thread)
      end

      it "should let you edit the thread" do
        click_on edit_thread
        expect(page).to have_content("Edit thread")
        fill_in I18n.t("activerecord.attributes.message_thread.title"), with: "New better title"
        click_on "Save"
        expect(page).to have_content("Thread updated")
        expect(page).to have_content("New better title")
      end

      it "should let you set a group as the owner" do
        group = create(:group)
        click_on edit_thread
        select group.name, from: "Owned by"
        click_on "Save"
        expect(page).to have_content(thread.title)
        expect(page).to have_content(group.name)
      end

      it "should let you pick an issue to assign the thread to" do
        issue = create(:issue)
        click_on edit_thread
        select "#{issue.id} - #{issue.title}", from: "Issue"
        click_on "Save"
        expect(page).to have_content(thread.title)
        expect(page).to have_content(issue.title)
      end
    end

    context "editing a group thread" do
      let!(:thread) { create(:group_message_thread) }
      let!(:other_group) { create(:group) }

      it "should let you assign to another group" do
        visit edit_thread_path(thread)
        expect(page).to have_select("Owned by", selected: thread.group.name)
        select other_group.name, from: "Owned by"
        click_on "Save"
        expect(page).to have_content(thread.title)
        expect(page).to have_content(other_group.name)
        expect(page).to have_no_content(thread.group.name)
      end

      it "should let you change the privacy setting" do
        visit edit_thread_path(thread)
        expect(page).to have_select("Privacy", selected: I18n.t("thread_privacy_options.public"))
        select I18n.t("thread_privacy_options.group"), from: "Privacy"
        click_on "Save"
        expect(page).to have_content(thread.title)
        expect(page).to have_content("Private")
      end
    end
  end

  context "privacy" do
    let(:private_thread) { create(:group_private_message_thread) }
    let(:committee_thread) { create(:group_committee_message_thread) }

    context "as a guest" do
      it "should not show the private thread" do
        visit thread_path(private_thread)
        expect(page).to have_content("You need to sign in or sign up before continuing.")
      end

      it "should not show the committee thread" do
        visit thread_path(committee_thread)
        expect(page).to have_content("You need to sign in or sign up before continuing.")
      end
    end

    context "as a signed in member" do
      include_context "signed in as a site user"

      it "should not show the private thread" do
        visit thread_path(private_thread)
        expect(page).to have_content(I18n.t("shared.permission_denied.login"))
      end

      it "should not show the committee thread" do
        visit thread_path(committee_thread)
        expect(page).to have_content(I18n.t("shared.permission_denied.login"))
      end
    end

    context "as a member of the correct group" do
      include_context "signed in as a group member"

      let(:group_private_thread) { create(:group_private_message_thread, group: current_group) }
      let(:group_committee_thread) { create(:group_committee_message_thread, group: current_group) }

      it "should show the private thread" do
        visit thread_path(group_private_thread)
        expect(page).to have_content(group_private_thread.title)
      end

      it "should not show the committee thread" do
        visit thread_path(group_committee_thread)
        expect(page).to have_content(I18n.t("shared.permission_denied.login"))
      end
    end

    context "as a committee member of the correct group" do
      include_context "signed in as a committee member"

      let(:group_private_thread) { create(:group_private_message_thread, group: current_group) }
      let(:group_committee_thread) { create(:group_committee_message_thread, group: current_group) }

      it "should show the private thread" do
        visit thread_path(group_private_thread)
        expect(page).to have_content(group_private_thread.title)
      end

      it "should show the committee thread" do
        visit thread_path(group_committee_thread)
        expect(page).to have_content(group_committee_thread.title)
      end
    end

    context "as an admin" do
      include_context "signed in as admin"

      it "should let admins see any thread" do
        visit thread_path(private_thread)
        expect(page).to have_content(private_thread.title)

        visit thread_path(committee_thread)
        expect(page).to have_content(committee_thread.title)
      end
    end
  end
end
