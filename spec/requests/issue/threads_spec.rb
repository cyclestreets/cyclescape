require "spec_helper"

describe "Issue threads" do
  let!(:issue) { FactoryGirl.create(:issue) }
  let(:edit_thread) { "Edit this thread" }

  context "new" do
    context "as a site user" do
      include_context "signed in as a site user"

      it "should create a new public thread" do
        visit issue_path(issue)
        click_on "Discuss"
        fill_in "Message", with: "Awesome!"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
        current_user.subscribed_to_thread?(issue.threads.last).should be_true
      end

      it "should pre-fill the title for the thread" do
        visit issue_path(issue)
        click_on "Discuss"
        find_field("Title").value.should eq(issue.title)
      end

      it "should not pre-fill the title for the second thread" do
        visit issue_path(issue)
        click_on "Discuss"
        fill_in "Message", with: "Awesome!"
        click_on "Create Thread"
        visit issue_path(issue)
        click_on "New Thread"
        find_field("Title").value.should be_nil
      end
    end

    context "as a group member" do
      include_context "signed in as a group member"

      it "should still create a new public thread" do
        visit issue_path(issue)
        click_on "Discuss"
        fill_in "Message", with: "Awesome!"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
        page.should have_content("Public: Everyone can view this thread and post messages.")
      end

      it "should create a new public group thread" do
        visit issue_path(issue)
        click_on "Discuss"
        select current_group.name, from: "Owned by"
        fill_in "Message", with: "Awesome!"
        select "Public", from: "Privacy"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
        page.should have_content("Public: Everyone can view this thread and post messages.")
      end

      it "should create a new private group thread" do
        visit issue_path(issue)
        click_on "Discuss"
        select current_group.name, from: "Owned by"
        fill_in "Message", with: "Awesome!"
        select "Group", from: "Privacy"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
        page.should have_content("Private: Only members of #{current_group.name} can view and post messages to this thread.")
      end

      context "in a subdomain", use: :current_subdomain do
        it "should default to be owned by the current group" do
          visit issue_path(issue)
          click_on "Discuss"
          # Done twice so it's clear what's failing, as the error is confusing
          page.should have_select("Owned by")
          page.should have_select("Owned by", selected: current_group.name)
        end

        it "should default to the group's privacy setting" do
          current_group.update_attribute(:default_thread_privacy, "group")
          visit issue_path(issue)
          click_on "Discuss"
          page.should have_select("Privacy")
          find_field("Privacy").value.should == "group"
        end
      end

      context "group thread notification" do
        let(:user) { FactoryGirl.create(:user) }
        # Non-conflicting name
        let(:group_membership) { FactoryGirl.create(:group_membership, group: current_group, user: user) }
        let(:notifiee) { group_membership.user }

        before do
          notifiee.prefs.update_attribute(:notify_new_group_thread, true)
          reset_mailer
        end

        def create_thread
          visit issue_path(issue)
          click_on "Discuss"
          select current_group.name, from: "Owned by"
          fill_in "Message", with: "Awesome!"
          click_on "Create Thread"
        end

        it "should be sent to other group members" do
          create_thread
          email = open_last_email_for(notifiee.email)
          email.should have_subject("[Cyclescape] \"#{issue.title}\" (#{current_group.name})")
        end

        context "with an unconfirmed user" do
          let(:user) { FactoryGirl.create(:user, :unconfirmed) }

          it "should not receive it" do
            create_thread
            email = open_last_email_for(notifiee.email)
            email.should be_nil
          end
        end
      end
    end

    context "user locations notifications" do
      # when a thread is created on an issue, and that issue overlaps a users locations, send notifications

      include_context "signed in as a group member"

      let(:notifiee) { FactoryGirl.create(:user) }
      let!(:notifiee_location_big) { FactoryGirl.create(:user_location, user: notifiee, location: issue.location.buffer(1)) }
      let!(:notifiee_location_small) { FactoryGirl.create(:user_location, user: notifiee, location: issue.location.buffer(0.1)) }
      let!(:user_location) { FactoryGirl.create(:user_location, user: current_user, location: issue.location.buffer(1)) }

      before do
        current_user.prefs.update_attribute(:notify_new_group_thread, false)
        notifiee.prefs.update_attribute(:notify_new_user_locations_issue_thread, true)
        reset_mailer
      end

      def create_thread
        visit issue_path(issue)
        click_on "Discuss"
        fill_in "Title", with: "Lorem & Ipsum"
        fill_in "Message", with: "Something or other"
        click_on "Create Thread"
      end

      it "should send a notification" do
        create_thread
        email = open_last_email_for(notifiee.email)
        email.should have_subject("[Cyclescape] New thread started on issue \"#{issue.title}\"")
        email.should have_body_text(issue.title)
        email.should have_body_text("Lorem & Ipsum")
        email.should have_body_text("Something or other")
        email.should have_body_text(current_user.name)
        #email.should contain the issue title, thread title and first message contents
      end

      it "should not send multiple notifications to the same person" do
        email_count = all_emails.count
        create_thread
        all_emails.count.should eql(email_count + 1)
      end

      it "should not send a notification if they don't have permission to view the thread" do
        visit issue_path(issue)
        click_on "Discuss"
        fill_in "Title", with: "Super secrets"
        select current_group.name, from: "Owned by"
        select "Group", from: "Privacy"
        fill_in "Message", with: "Don't tell anyone, but..."

        email_count = all_emails.count
        click_on "Create Thread"
        all_emails.count.should eql(email_count)

        email = open_last_email_for(notifiee.email)
        email.should be_nil
      end

      it "should not send a notification to the person who started the thread" do
        current_user.prefs.update_attribute(:notify_new_user_locations_issue_thread, true)
        create_thread
        email = open_last_email_for(current_user.email)
        email.should be_nil
      end

      it "should not send a notification to anyone who is auto-subscribed to the thread"
    end

    context "automatic subscriptions" do
      include_context "signed in as a site user"

      let(:subscriber) { FactoryGirl.create(:user) }
      let!(:subscriber_location) { FactoryGirl.create(:user_location, user: subscriber, location: issue.location.buffer(1)) }

      def create_thread
        visit issue_path(issue)
        click_on "Discuss"
        fill_in "Title", with: "Lorem & Ipsum"
        fill_in "Message", with: "Something or other"
        click_on "Create Thread"
      end


      it "should not automatically subscribe people with overlapping locations" do
        create_thread
        subscriber.subscribed_to_thread?(issue.threads.last).should be_false
      end

      it "should subscribe when the preference is set" do
        subscriber.prefs.update_attribute(:subscribe_new_user_location_issue_thread, true)
        create_thread
        subscriber.subscribed_to_thread?(issue.threads.last).should be_true
      end
    end
  end

  context "edit" do
    let(:thread) { FactoryGirl.create(:message_thread, issue: issue, group: current_group) }

    context "as a group member" do
      include_context "signed in as a group member"

      it "should not let you" do
        visit issue_thread_path(issue, thread)
        page.should have_content(issue.title)
        page.should have_content(thread.title)
        page.should_not have_content(edit_thread)
      end
    end

    context "as a group committee member" do
      include_context "signed in as a committee member"

      it "should let you edit the thread" do
        visit issue_thread_path(issue, thread)
        click_on edit_thread
        fill_in "Title", with: "New title please"
        click_on "Save"
        page.should have_content("Thread updated")
        page.should have_content("New title please")
      end
    end
  end

  context "group private thread" do
    let!(:thread) { FactoryGirl.create(:group_private_message_thread, issue: issue) }
    context "as an admin" do
      include_context "signed in as admin"

      it "should show you a link to the thread" do
        visit issue_path(issue)
        page.should have_content(thread.title)
        page.should have_content("Group Private")
        page.should have_link(thread.title)
      end
    end
  end

  context "when showing" do
    context "a non-group public thread in a subdomain", use: :current_subdomain do
      include_context "signed in as a group member"

      let!(:thread) { FactoryGirl.create(:message_thread, issue: issue) }

      it "should be accessible" do
        visit issue_path(issue)
        click_on thread.title
        page.should have_content(thread.title)
      end
    end
  end
end
