require "spec_helper"

describe "Message threads" do
  let(:thread) { FactoryGirl.create(:message_thread_with_messages, :with_tags) }
  let(:threads) { FactoryGirl.create_list(:message_thread_with_messages, 5) }
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
          page.should have_content(thread.title)
        end
      end

      it "should not show private message threads"
      it "should list threads by latest first"
    end

    context "show" do
      before do
        threads
        @thread = threads.first
        @messages = @thread.messages
        visit threads_path
        click_link @thread.title
      end

      it "should show the thread title" do
        within(".thread h1") do
          page.should have_content(@thread.title)
        end
      end

      it "should show messages on a public thread" do
        @messages.each do |message|
          page.should have_content(message.body)
        end
      end

      it "should show the authors of messages" do
        @messages.each do |message|
          within(dom_id_selector(message)) do
            page.should have_content(message.created_by.name)
          end
        end
      end

      it "should not show a link to edit tags" do
        page.should_not have_content(I18n.t(".shared.tags.panel.edit_tags"))
      end

      it "should set the page title" do
        within "title" do
          page.should have_content(@thread.title)
        end
      end

      it "should disable the message input" do
        find("#message_body")[:disabled].should == "disabled"
      end

      it "should display a notice saying the user must sign in to post" do
        page.should have_content("Please sign in to post a message")
      end
    end

    context "deleted issue" do
      let(:thread_with_issue) { FactoryGirl.create(:issue_message_thread) }
      let(:issue) { thread_with_issue.issue }

      before do
        #issue = thread_with_issue.issue
        thread_with_issue.issue.destroy
        visit thread_path(thread_with_issue)
      end

      it "should not show the issue" do
        page.should_not have_content(issue.title)
      end

      it "should still show the thread" do
        page.should have_content(thread_with_issue.title)
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
          page.should have_content(thread.title)
        end
      end

      it "should indicate which threads I follow" do
        first = threads.first
        first.add_subscriber(current_user)
        visit threads_path
        within("li[data-thread-id='#{first.id}']") do
          page.should have_content("Following")
        end
      end

      it "should link to the issue" do
        issue_thread = FactoryGirl.create(:issue_message_thread, :with_messages)
        visit threads_path
        page.should have_link(issue_thread.issue.title)
      end
    end

    context "show" do
      before do
        visit thread_path(thread)
      end

      context "messages" do
        it "should show all messages" do
          thread.messages.each do |message|
            page.should have_content(message.body)
          end
        end

        it "should be able to post a new message" do
          fill_in "Message", with: "Testing a new message!"
          click_on "Post Message"
          page.should have_content("Testing a new message!")
        end

        it "should auto link messages" do
          fill_in "Message", with: "Testing autolink http://example.com"
          click_on "Post Message"
          page.should have_link("http://example.com")
        end

        it "should not be disabled as it is for guests" do
          page.should have_no_content("Please sign in to post a message")
        end
      end

      context "subscribers" do
        it "should show the names of subscribers" do
          click_on "Follow this thread"
          within(".subscribers") do
            page.should have_content(current_user.name)
          end
        end
      end

      context "censoring"  do
        it "should not have a censor link" do
          page.should_not have_content(censor_message)
        end

        it "should not let you censor a message" do
          page.driver.put censor_thread_message_path(thread, thread.messages[0])
          page.should have_content("You are not authorised to access that page.")
        end
      end

      context "tags" do
        it "should show the linked tags" do
          thread.tags.each do |tag|
            page.should have_content(tag.name)
          end
        end

        it "should edit the tags" do
          # This form is initially hidden
          within("form.edit-tags") do
            fill_in "Tags", with: "bike wheels"
            click_on I18n.t(".formtastic.actions.message_thread.update_tags")
          end
          # Page submission is AJAX and returns json
          page.source.should have_content("bike")
          page.source.should have_content("wheels")
          # Check the response has information for the library panel.
          JSON.parse(page.source)["librarypanel"].should_not be_nil
        end
      end
    end

    context "delete" do
      before do
        visit thread_path(thread)
      end

      it "should not show a delete link" do
        page.should_not have_content(delete_thread)
      end

      it "should not let you delete a thread" do
        page.driver.delete thread_path(thread)
        page.should have_content("You are not authorised to access that page.")
      end
    end

    context "edit" do
      before do
        visit thread_path(thread)
      end

      it "should not show an edit link" do
        page.should_not have_content(edit_thread)
      end

      it "should not let you edit a thread" do
        visit edit_thread_path(thread)
        page.should have_content("You are not authorised to access that page.")
      end
    end
  end

  context "as an admin user" do
    include_context "signed in as admin"

    context "index" do
      before do
        threads
        visit threads_path
      end

      it "should list all message threads"
    end

    context "message censoring" do

      before do
        visit thread_path(thread)
      end

      it "should provide a censor link" do
        page.should have_content(censor_message)
      end

      it "should let you censor a message" do
        click_on censor_message
        page.should have_content("Message censored")
        page.should have_content("This message has been removed")
      end

      it "should still show messages in order of creation and not updated"
    end

    context "thread deletion" do

      before do
        visit thread_path(thread)
      end

      it "should let you delete the thread" do
        click_on delete_thread
        page.should have_content("Thread deleted")
        page.should_not have_content(thread.title)
      end
    end

    context "thread editing" do
      before do
        visit thread_path(thread)
      end

      it "should let you edit the thread" do
        click_on edit_thread
        page.should have_content("Edit thread")
        fill_in "Title", with: "New better title"
        click_on "Save"
        page.should have_content("Thread updated")
        page.should have_content("New better title")
      end

      it "should let you set a group as the owner" do
        group = FactoryGirl.create(:group)
        click_on edit_thread
        select group.name, from: "Owned by"
        click_on "Save"
        page.should have_content(thread.title)
        page.should have_content(group.name)
      end

      it "should let you pick an issue to assign the thread to" do
        issue = FactoryGirl.create(:issue)
        click_on edit_thread
        select "#{issue.id} - #{issue.title}", from: "Issue"
        click_on "Save"
        page.should have_content(thread.title)
        page.should have_content(issue.title)
      end
    end

    context "editing a group thread" do
      let!(:thread) { FactoryGirl.create(:group_message_thread) }
      let!(:other_group) { FactoryGirl.create(:group) }

      it "should let you assign to another group" do
        visit edit_thread_path(thread)
        page.should have_select("Owned by", with: thread.group.name)
        select other_group.name, from: "Owned by"
        click_on "Save"
        page.should have_content(thread.title)
        page.should have_content(other_group.name)
        page.should have_no_content(thread.group.name)
      end

      it "should let you change the privacy setting" do
        visit edit_thread_path(thread)
        page.should have_select("Privacy", with: "Public")
        select "Group", from: "Privacy"
        click_on "Save"
        page.should have_content(thread.title)
        page.should have_content("Private")
      end
    end
  end

  context "privacy" do
    let(:private_thread) { FactoryGirl.create(:group_private_message_thread) }
    let(:committee_thread) { FactoryGirl.create(:group_committee_message_thread) }

    context "as a guest" do
      it "should not show the private thread" do
        visit thread_path(private_thread)
        page.should have_content("You need to sign in or sign up before continuing.")
      end

      it "should not show the committee thread" do
        visit thread_path(committee_thread)
        page.should have_content("You need to sign in or sign up before continuing.")
      end
    end

    context "as a signed in member" do
      include_context "signed in as a site user"

      it "should not show the private thread" do
        visit thread_path(private_thread)
        page.should have_content("You are not authorised to access that page.")
      end

      it "should not show the committee thread" do
        visit thread_path(committee_thread)
        page.should have_content("You are not authorised to access that page.")
      end
    end

    context "as a member of the correct group" do
      include_context "signed in as a group member"

      let(:group_private_thread) { FactoryGirl.create(:group_private_message_thread, group: current_group) }
      let(:group_committee_thread) { FactoryGirl.create(:group_committee_message_thread, group: current_group) }

      it "should show the private thread" do
        visit thread_path(group_private_thread)
        page.should have_content(group_private_thread.title)
      end

      it "should not show the committee thread" do
        visit thread_path(group_committee_thread)
        page.should have_content("You are not authorised to access that page.")
      end
    end

    context "as a committee member of the correct group" do
      include_context "signed in as a committee member"

      let(:group_private_thread) { FactoryGirl.create(:group_private_message_thread, group: current_group) }
      let(:group_committee_thread) { FactoryGirl.create(:group_committee_message_thread, group: current_group) }

      it "should show the private thread" do
        visit thread_path(group_private_thread)
        page.should have_content(group_private_thread.title)
      end

      it "should show the committee thread" do
        visit thread_path(group_committee_thread)
        page.should have_content(group_committee_thread.title)
      end
    end

    context "as an admin" do
      include_context "signed in as admin"

      it "should let admins see any thread" do
        visit thread_path(private_thread)
        page.should have_content(private_thread.title)

        visit thread_path(committee_thread)
        page.should have_content(committee_thread.title)
      end
    end
  end

  context "search" do
    let(:search_field) { "query" }
    let(:search_button) { I18n.t("layouts.search.search_button") }

    before do
        [thread, private_thread, committee_thread].each do |t|
          m = t.messages.new(body: "Findable with bananas")
          m.created_by = FactoryGirl.create(:user)
          m.save!
          t.reload
        end
    end

    describe "as a guest" do
      let(:thread) { FactoryGirl.create(:message_thread) }
      let(:private_thread) { FactoryGirl.create(:group_private_message_thread) }
      let(:committee_thread) { FactoryGirl.create(:group_committee_message_thread) }

      it "should show one result" do
        visit threads_path
        within('.main-search-box') do
          fill_in search_field, with: "bananas"
          click_on search_button
        end
        page.should have_content(thread.title)
        page.should_not have_content(private_thread.title)
        page.should_not have_content(committee_thread.title)
      end
    end

    describe "as a group member" do
      include_context "signed in as a group member"

      let(:private_thread) { FactoryGirl.create(:group_private_message_thread, group: current_group) }
      let(:committee_thread) { FactoryGirl.create(:group_committee_message_thread, group: current_group) }

      it "should show two results" do
        visit threads_path
        within('.main-search-box') do
          fill_in search_field, with: "bananas"
          click_on search_button
        end
        page.should have_content(thread.title)
        page.should have_content(private_thread.title)
        page.should_not have_content(committee_thread.title)
      end
    end

    describe "as a committee member" do
      include_context "signed in as a committee member"

      let(:private_thread) { FactoryGirl.create(:group_private_message_thread, group: current_group) }
      let(:committee_thread) { FactoryGirl.create(:group_committee_message_thread, group: current_group) }

      it "should show three results" do
        visit threads_path
        within('.main-search-box') do
          fill_in search_field, with: "bananas"
          click_on search_button
        end
        page.should have_content(thread.title)
        page.should have_content(private_thread.title)
        page.should have_content(committee_thread.title)
      end
    end
  end
end
