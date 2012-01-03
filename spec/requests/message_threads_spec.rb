require "spec_helper"

describe "Message threads" do
  let(:thread) { FactoryGirl.create(:message_thread_with_messages, :with_tags) }
  let(:threads) { FactoryGirl.create_list(:message_thread_with_messages, 5) }
  let(:censor_message) { "Censor this message" }
  let(:delete_thread) { "Delete this thread" }

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
        visit threads_path
      end

      it "should list all public message threads" do
        threads.each do |thread|
          page.should have_content(thread.title)
        end
      end

      it "should list threads the user has created"
      it "should list all threads the user has been invited to"
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
            click_on "Save"
          end
          # Page submission is AJAX but returns usable page fragment here
          page.should have_content("bike")
          page.should have_content("wheels")
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
  end

  context "privacy" do
    let(:private_thread) { FactoryGirl.create(:group_private_message_thread) }

    context "as a guest" do
      it "should not show the private thread" do
        visit thread_path(private_thread)
        page.should have_content("You need to sign in or sign up before continuing.")
      end
    end

    context "as a signed in member" do
      include_context "signed in as a site user"

      it "should not show the private thread" do
        visit thread_path(private_thread)
        page.should have_content("You are not authorised to access that page.")
      end
    end

    context "as a member of the correct group" do
      include_context "signed in as a group member"

      let(:group_private_thread) { FactoryGirl.create(:group_private_message_thread, group: current_group) }

      it "should show the private thread" do
        visit thread_path(group_private_thread)
        page.should have_content(group_private_thread.title)
      end
    end

    context "as an admin" do
      include_context "signed in as admin"

      it "should let admins see any thread" do
        visit thread_path(private_thread)
        page.should have_content(private_thread.title)
      end
    end
  end
end
