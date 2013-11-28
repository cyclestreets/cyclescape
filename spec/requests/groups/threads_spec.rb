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

      def fill_in_thread
        fill_in "Title", with: thread_attrs[:title]
        fill_in "Message", with: "This is between you an me, but..."
        click_on "Create Thread"
      end

      before do
        visit group_threads_path(current_group)
        click_link I18n.t("group.message_threads.index.new_group_thread")
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

      it "should create a new committee thread" do
        fill_in "Title", with: thread_attrs[:title]
        fill_in "Message", with: "This is between you an me, but..."
        select "Committee", from: "Privacy"
        click_on "Create Thread"
        page.should have_content("Private: Only committee members of #{current_group.name}")
      end

      it "should default to a public group thread" do
        page.should have_select("Privacy", with: "Public")
      end

      context "notifications" do

        def enable_group_thread_prefs_for(u)
          u.prefs.update_column(:involve_my_groups, "notify")
          u.prefs.update_column(:involve_my_groups_admin, true)
          u.prefs.update_column(:enable_email, true)
        end

        it "should send a notification to group members" do
          membership = FactoryGirl.create(:group_membership, group: current_group)
          notifiee = membership.user
          enable_group_thread_prefs_for(notifiee)
          fill_in_thread
          email = open_last_email_for(notifiee.email)
          email.should have_subject("[Cyclescape] \"#{thread_attrs[:title]}\" (#{current_group.name})")
        end

        it "should not send html entities in the notification" do
          membership = FactoryGirl.create(:group_membership, group: current_group)
          notifiee = membership.user
          enable_group_thread_prefs_for(notifiee)
          fill_in "Title", with: "Something like A & B"
          fill_in "Message", with: "A & B is something important"
          click_on "Create Thread"
          email = open_last_email_for(notifiee.email)
          email.should have_subject(/like A & B/)
          email.should have_body_text("A & B is")
          email.should_not have_body_text("&amp;")
        end

        it "should not send emails if the notifiee dislikes emails" do
          membership = FactoryGirl.create(:group_membership, group: current_group)
          notifiee = membership.user
          enable_group_thread_prefs_for(notifiee)
          notifiee.prefs.update_column(:enable_email, false)
          fill_in_thread
          open_last_email_for(notifiee.email).should be_nil
        end

        it "should not send emails if the notifiee dislikes administrative fluff" do
          membership = FactoryGirl.create(:group_membership, group: current_group)
          notifiee = membership.user
          enable_group_thread_prefs_for(notifiee)
          notifiee.prefs.update_column(:involve_my_groups_admin, false)
          fill_in_thread
          open_last_email_for(notifiee.email).should be_nil
        end

        it "should not be sent if the group member has not confirmed" do
          user = FactoryGirl.create(:user, :unconfirmed)
          membership = FactoryGirl.create(:group_membership, group: current_group, user: user)
          reset_mailer  # Clear out confirmation email
          notifiee = membership.user
          enable_group_thread_prefs_for(notifiee)
          fill_in_thread
          open_last_email_for(notifiee.email).should be_nil
        end

        it "should not send double notifications to auto-subscribers" do
          # if you auto-subscribe, you shouldn't also get the new thread notification.
          membership = FactoryGirl.create(:group_membership, group: current_group)
          notifiee = membership.user
          enable_group_thread_prefs_for(notifiee)
          notifiee.prefs.update_column(:involve_my_groups, "subscribe")
          fill_in_thread

          mailbox = mailbox_for(notifiee.email)
          mailbox.count.should eql(1)
        end

        context "on committee-only threads" do
          it "should not send a notification to a normal member" do
            membership = FactoryGirl.create(:group_membership, group: current_group)
            notifiee = membership.user
            enable_group_thread_prefs_for(notifiee)
            fill_in "Title", with: thread_attrs[:title]
            fill_in "Message", with: "Something"
            select "Committee", from: "Privacy"
            click_on "Create Thread"
            open_last_email_for(notifiee.email).should be_nil
          end

          it "should send a notification to a committee member" do
            membership = FactoryGirl.create(:group_membership, group: current_group, role: "committee")
            notifiee = membership.user
            enable_group_thread_prefs_for(notifiee)
            fill_in "Title", with: thread_attrs[:title]
            fill_in "Message", with: "Something"
            select "Committee", from: "Privacy"
            click_on "Create Thread"
            email = open_last_email_for(notifiee.email)
            email.should have_subject("[Cyclescape] \"#{thread_attrs[:title]}\" (#{current_group.name})")
          end
        end

        context "group threads on an issue" do
          let(:location) { "POLYGON ((0.1 0.1, 0.1 0.2, 0.2 0.2, 0.2 0.1, 0.1 0.1))" }
          let(:user) { FactoryGirl.create(:user) }
          let!(:user_location) { FactoryGirl.create(:user_location, user: user, location: location) }
          let!(:group_membership) { FactoryGirl.create(:group_membership, user: user, group: current_group) }
          let!(:issue) { FactoryGirl.create(:issue, location: user_location.location) }

          before do
            enable_group_thread_prefs_for(user)
            user.prefs.update_column(:involve_my_locations, "notify")
            visit issue_path(issue)
            click_on "Discuss"
            fill_in "Title", with: thread_attrs[:title]
            fill_in "Message", with: "Something"
            select current_group.name, from: "Owned by"
          end

          # The user would normally receive an email since it's a new group thread,
          # but it's also a new thread on an issue within one of their locations.
          it "should not send two emails to the same person" do
            email_count = all_emails.count
            click_on "Create Thread"
            all_emails.count.should eql(email_count + 1)
          end
        end
      end

      context "automatic subscriptions" do
        let!(:group_membership) { FactoryGirl.create(:group_membership, group: current_group) }
        let!(:subscriber) { group_membership.user }

        it "should not subscribe people automatically" do
          fill_in_thread
          subscriber.subscribed_to_thread?(current_group.threads.last).should be_false
        end

        it "should subscribe people with the correct preference" do
          subscriber.prefs.update_column(:involve_my_groups, "subscribe")
          subscriber.prefs.update_column(:involve_my_groups_admin, true)
          fill_in_thread
          subscriber.subscribed_to_thread?(current_group.threads.last).should be_true
        end

        it "should not subscribe normal members to committee threads" do
          subscriber.prefs.update_column(:involve_my_groups, "subscribe")
          subscriber.prefs.update_column(:involve_my_groups_admin, true)
          fill_in "Title", with: "Committee Thread"
          fill_in "Message", with: "Something secret"
          select "Committee", from: "Privacy"
          click_on "Create Thread"
          subscriber.subscribed_to_thread?(current_group.threads.last).should be_false
        end

        context "to private group threads" do
          let(:issue) { FactoryGirl.create(:issue) }
          let(:stranger) { FactoryGirl.create(:user) }
          let!(:stranger_location) { FactoryGirl.create(:user_location, user: stranger, location: issue.location.buffer(1)) }
          let(:stewie) { FactoryGirl.create(:stewie) }
          let!(:stewie_location) { FactoryGirl.create(:user_location, user: stewie, location: issue.location.buffer(1)) }

          def create_private_group_thread
            visit issue_path(issue)
            click_on "Discuss"
            fill_in "Title", with: "Private thread"
            fill_in "Message", with: "Something or other"
            select "Group", from: "Privacy"
            click_on "Create Thread"

            current_group.threads.last.privacy.should eql("group")
          end

          it "should not autosubscribe non-members with overlapping areas" do
            stranger.prefs.update_column(:involve_my_locations, "subscribe")
            create_private_group_thread

            stranger.subscribed_to_thread?(current_group.threads.last).should be_false
          end

          it "should not autosubscribe administrators with overlapping areas" do
            # because it gets annoying fast, trust me.
            stewie.prefs.update_column(:involve_my_locations, "subscribe")
            create_private_group_thread

            stewie.subscribed_to_thread?(current_group.threads.last).should be_false
          end
        end
      end
    end

    context "in a secretive group" do
      before do
        current_group.default_thread_privacy = "group"
        current_group.save
        visit group_threads_path(current_group)
        click_link I18n.t("group.message_threads.index.new_group_thread")
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

  context "as a group member" do
    include_context "signed in as a group member"

    context "new threads" do
      before do
        visit group_threads_path(current_group)
        click_link I18n.t("group.message_threads.index.new_group_thread")
      end

      it "should not let you create committee threads" do
        page.should have_select("Privacy", options: ['Group'])
        page.should_not have_select("Privacy", options: ['Committee'])
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
    let(:private_thread) { FactoryGirl.create(:group_private_message_thread, :with_messages) }

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

    context "thread listing as a site user" do
      include_context "signed in as a site user"

      before do
        visit group_threads_path(private_thread.group)
      end

      it "should not show the title of private threads" do
        page.should_not have_content(private_thread.title)
        page.should have_content(I18n.t("decorators.thread_list.private_thread_title"))
      end

      it "should not show the last user who posted" do
        page.should_not have_link(private_thread.latest_activity_by.name)
      end
    end
  end
end
