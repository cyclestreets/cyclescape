require "spec_helper"

describe "Group threads", use: :subdomain do
  let(:thread) { FactoryGirl.create(:message_thread, group: current_group) }
  let(:threads) { FactoryGirl.create_list(:message_thread_with_messages, 5, group: current_group) }
  let(:edit_thread) { "Edit this thread" }
  let(:delete_thread) { "Delete this thread" }

  before { set_subdomain(current_group.subdomain) if defined?(current_group) }
  after  { unset_subdomain if defined?(current_group) }

  context "as a group committee member" do
    include_context "signed in as a committee member"

    context "index page" do
      before do
        threads
        visit group_threads_path(current_group)
      end

      it "should list threads belonging to the group" do
        threads.each do |thread|
          page.should have_content(thread.title)
        end
      end
    end

    context "new thread" do
      let(:thread_attrs) { FactoryGirl.attributes_for(:message_thread) }

      before do
        visit group_threads_path(current_group)
        click_link "New Group Thread"
      end

      it "should create a new public thread" do
        fill_in "Title", with: thread_attrs[:title]
        fill_in "Message", with: "Damn you, woman, awake from your damnable reverie!"
        select "Public", from: "Privacy"
        click_on "Create Thread"
        page.should have_content(thread_attrs[:title])
        current_user.subscribed_to_thread?(current_group.threads.last).should be_true
      end

      it "should create a new private thread" do
        fill_in "Title", with: thread_attrs[:title]
        fill_in "Message", with: "This is between you an me, but..."
        select "Group", from: "Privacy"
        click_on "Create Thread"
        page.should have_content("Private: Only members of #{current_group.name}")
      end

      it "should default to a public group thread" do
        page.should have_select("Privacy", with: "Public")
      end

      context "notifications" do
        def fill_in_thread
          fill_in "Title", with: thread_attrs[:title]
          fill_in "Message", with: "This is between you an me, but..."
          click_on "Create Thread"
        end

        it "should send a notification to group members" do
          membership = FactoryGirl.create(:group_membership, group: current_group)
          notifiee = membership.user
          notifiee.prefs.update_attribute(:notify_new_group_thread, true)
          fill_in_thread
          email = open_last_email_for(notifiee.email)
          email.should have_subject("[Cyclescape] \"#{thread_attrs[:title]}\" (#{current_group.name})")
        end

        it "should not send html entities in the notification" do
          membership = FactoryGirl.create(:group_membership, group: current_group)
          notifiee = membership.user
          notifiee.prefs.update_attribute(:notify_new_group_thread, true)
          fill_in "Title", with: "Something like A & B"
          fill_in "Message", with: "A & B is something important"
          click_on "Create Thread"
          email = open_last_email_for(notifiee.email)
          email.should have_subject(/like A & B/)
          email.should have_body_text("A & B is")
          email.should_not have_body_text("&amp;")
        end

        it "should not be sent if the group member has not confirmed" do
          user = FactoryGirl.create(:user, :unconfirmed)
          membership = FactoryGirl.create(:group_membership, group: current_group, user: user)
          reset_mailer  # Clear out confirmation email
          notifiee = membership.user
          notifiee.prefs.update_attribute(:notify_new_group_thread, true)
          fill_in_thread
          open_last_email_for(notifiee.email).should be_nil
        end
      end
    end

    context "in a secretive group" do
      before do
        current_group.default_thread_privacy = "group"
        current_group.save
        visit group_threads_path(current_group)
        click_link "New Group Thread"
      end

      it "should default to a private group thread" do
        page.should have_select("Privacy", with: "Group")
      end
    end

    context "showing a thread" do
      before do
        visit group_thread_path(current_group, thread)
      end

      it "should show the thread title" do
        page.should have_content(thread.title)
      end

      it "should have fields to create a new message" do
        page.should have_field("Message")
      end

      it "should display all the messages in chronological order"
      it "should show who started the thread"
    end

    context "edit a thread" do
      before do
        visit group_thread_path(current_group, thread)
      end

      it "should let you edit the thread" do
        page.should have_content(edit_thread)
        click_on edit_thread
        fill_in "Title", with: "New, better, thread title"
        click_on "Save"
        page.should have_content "Thread updated"
        page.should have_content "New, better, thread title"
      end
    end
  end

  context "thread deletion" do
    context "as an admin user" do
      include_context "signed in as admin"

      let(:group) { FactoryGirl.create(:group) }
      let(:thread) { FactoryGirl.create(:message_thread, group: group) }

      before do
        visit group_thread_path(group, thread)
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
        visit group_thread_path(private_thread.group, private_thread)
        page.should have_content("You need to sign in or sign up before continuing.")
      end
    end

    context "as a signed in member" do
      include_context "signed in as a site user"

      it "should not show the private thread" do
        visit group_thread_path(private_thread.group, private_thread)
        page.should have_content("You are not authorised to access that page.")
      end
    end

    context "as a member of the correct group" do
      include_context "signed in as a group member"

      let(:group_private_thread) { FactoryGirl.create(:group_private_message_thread, group: current_group) }

      it "should show the private thread" do
        visit group_thread_path(group_private_thread.group, group_private_thread)
        page.should have_content(group_private_thread.title)
      end

      it "should not let you edit the thread" do
        page.should_not have_content(edit_thread)
      end
    end

    context "as an admin" do
      include_context "signed in as admin"

      it "should let admins see any thread" do
        visit group_thread_path(private_thread.group, private_thread)
        page.should have_content(private_thread.title)
      end
    end
  end
end
