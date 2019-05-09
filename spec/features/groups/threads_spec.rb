# frozen_string_literal: true

require "spec_helper"

describe "Group threads", use: :subdomain do
  let(:thread) { create(:message_thread, group: current_group) }
  let(:threads) { create_list(:message_thread_with_messages, 5, group: current_group) }
  let(:edit_thread) { "Edit this thread" }
  let(:delete_thread) { "Delete this thread" }

  before { set_subdomain(current_group.subdomain) if defined?(current_group) }
  after  { unset_subdomain if defined?(current_group) }

  let(:thread_title) { "Like A & B" }

  def fill_in_thread
    fill_in I18n.t("activerecord.attributes.message_thread.title"), with: thread_title
    fill_in "Message", with: "This is between you & me, but..."
    click_on "Create Thread"
  end

  context "as a group committee member" do
    include_context "signed in as a committee member"

    context "index page" do
      before do
        threads
        visit group_threads_path(current_group)
      end

      it "should list threads belonging to the group" do
        threads.each do |thread|
          expect(page).to have_content(thread.title)
        end
      end
    end

    context "new thread" do
      before do
        visit group_threads_path(current_group)
        click_link I18n.t("group.message_threads.index.new_group_thread")
      end

      it "should create a new public thread" do
        select "Group", from: "Privacy"
        fill_in_thread
        expect(page).to have_content("Private: Only members of #{current_group.name}")
        expect(page).to have_content(thread_title)
        expect(current_user.subscribed_to_thread?(current_group.threads.last)).to be_truthy
      end

      it "should create a new committee thread" do
        select "Committee", from: "Privacy"
        fill_in_thread
        expect(page).to have_content("Private: Only committee members of #{current_group.name}")
      end

      it "should default to a public group thread" do
        expect(page).to have_select("Privacy", selected: I18n.t("thread_privacy_options.public"))
      end

      context "notifications" do
        def enable_group_thread_prefs_for(u)
          u.prefs.update!(involve_my_groups: "notify", involve_my_groups_admin: true, email_status_id: 1)
        end

        it "should send a notification to group members" do
          membership = create(:group_membership, group: current_group)
          notifiee = membership.user
          enable_group_thread_prefs_for(notifiee)
          fill_in_thread
          email = open_last_email_for(notifiee.email)
          expect(email).to have_subject("[Cyclescape] \"#{thread_title}\" (#{current_group.name})")
          expect(email).to have_body_text("between you & me")
          expect(email).not_to have_body_text("&amp;")
        end

        it "should not send emails if the notifiee dislikes emails" do
          membership = create(:group_membership, group: current_group)
          notifiee = membership.user
          enable_group_thread_prefs_for(notifiee)
          notifiee.prefs.update_column(:email_status_id, 0)
          fill_in_thread
          expect(open_last_email_for(notifiee.email)).to be_nil
        end

        it "should not send emails if the notifiee dislikes administrative fluff" do
          membership = create(:group_membership, group: current_group)
          notifiee = membership.user
          enable_group_thread_prefs_for(notifiee)
          notifiee.prefs.update_column(:involve_my_groups_admin, false)
          fill_in_thread
          expect(open_last_email_for(notifiee.email)).to be_nil
        end

        it "should not be sent if the group member has not confirmed" do
          user = create(:user, :unconfirmed)
          membership = create(:group_membership, group: current_group, user: user)
          reset_mailer # Clear out confirmation email
          notifiee = membership.user
          enable_group_thread_prefs_for(notifiee)
          fill_in_thread
          expect(open_last_email_for(notifiee.email)).to be_nil
        end

        it "should not send double notifications to auto-subscribers" do
          # if you auto-subscribe, you shouldn't also get the new thread notification.
          membership = create(:group_membership, group: current_group)
          notifiee = membership.user
          enable_group_thread_prefs_for(notifiee)
          notifiee.prefs.update_column(:involve_my_groups, "subscribe")
          fill_in_thread

          mailbox = mailbox_for(notifiee.email)
          expect(mailbox.count).to eql(1)
        end

        context "on committee-only threads" do
          it "should not send a notification to a normal member" do
            membership = create(:group_membership, group: current_group)
            notifiee = membership.user
            enable_group_thread_prefs_for(notifiee)
            select "Committee", from: "Privacy"
            fill_in_thread
            expect(open_last_email_for(notifiee.email)).to be_nil
          end

          it "should send a notification to a committee member" do
            membership = create(:group_membership, group: current_group, role: "committee")
            notifiee = membership.user
            enable_group_thread_prefs_for(notifiee)
            select "Committee", from: "Privacy"
            fill_in_thread
            email = open_last_email_for(notifiee.email)
            expect(email).to have_subject("[Cyclescape] \"#{thread_title}\" (#{current_group.name})")
          end
        end

        context "group threads on an issue" do
          let(:location) { "POLYGON ((0.1 0.1, 0.1 0.2, 0.2 0.2, 0.2 0.1, 0.1 0.1))" }
          let(:user) { create(:user) }
          let!(:user_location) { create(:user_location, user: user, location: location) }
          let!(:group_membership) { create(:group_membership, user: user, group: current_group) }
          let!(:issue) { create(:issue, location: user_location.location) }
          let(:email_count) { all_emails.count }

          before do
            email_count
            enable_group_thread_prefs_for(user)
            user.prefs.update_column(:involve_my_locations, "notify")
            visit issue_path(issue)
            click_on "Discuss"
            select current_group.name, from: "Owned by"
            fill_in_thread
          end

          # The user would normally receive an email since it's a new group thread,
          # but it's also a new thread on an issue within one of their locations.
          it "should not send two emails to the same person" do
            expect(all_emails.count).to eq(email_count + 1)
          end
        end
      end

      context "automatic subscriptions" do
        let!(:group_membership) { create(:group_membership, group: current_group) }
        let!(:subscriber) { group_membership.user }

        it "should not subscribe people automatically" do
          fill_in_thread
          expect(subscriber.subscribed_to_thread?(current_group.threads.last)).to be_falsey
        end

        it "should subscribe people with the correct preference" do
          subscriber.prefs.update_column(:involve_my_groups, "subscribe")
          subscriber.prefs.update_column(:involve_my_groups_admin, true)
          fill_in_thread
          expect(subscriber.subscribed_to_thread?(current_group.threads.last)).to be_truthy
        end

        it "should only subscribe the thread creator once" do
          current_user.prefs.update_column(:involve_my_groups, "subscribe")
          current_user.prefs.update_column(:involve_my_groups_admin, true)
          fill_in_thread
          expect(current_user.thread_subscriptions.count).to eq(1)
        end

        it "should not subscribe normal members to committee threads" do
          subscriber.prefs.update!(involve_my_groups: "subscribe", involve_my_groups_admin: true)

          fill_in I18n.t("activerecord.attributes.message_thread.title"), with: "Committee Thread"
          fill_in "Message", with: "Something secret"
          select "Committee", from: "Privacy"
          click_on "Create Thread"
          expect(subscriber.subscribed_to_thread?(current_group.threads.last)).to be_falsey
        end

        context "to private group threads" do
          let(:issue) { create(:issue) }
          let(:stranger) { create(:user) }
          let!(:stranger_location) { create(:user_location, user: stranger, location: issue.location.buffer(1)) }
          let(:stewie) { create(:stewie) }
          let!(:stewie_location) { create(:user_location, user: stewie, location: issue.location.buffer(1)) }

          def create_private_group_thread
            visit issue_path(issue)
            click_on "Discuss"
            fill_in I18n.t("activerecord.attributes.message_thread.title"), with: "Private thread"
            fill_in "Message", with: "Something or other"
            select "Group", from: "Privacy"
            click_on "Create Thread"

            expect(current_group.threads.last.privacy).to eq("group")
          end

          it "should not autosubscribe non-members with overlapping areas" do
            stranger.prefs.update_column(:involve_my_locations, "subscribe")
            create_private_group_thread

            expect(stranger.subscribed_to_thread?(current_group.threads.last)).to be_falsey
          end

          it "should not autosubscribe administrators with overlapping areas" do
            # because it gets annoying fast, trust me.
            stewie.prefs.update_column(:involve_my_locations, "subscribe")
            create_private_group_thread

            expect(stewie.subscribed_to_thread?(current_group.threads.last)).to be_falsey
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
        expect(page).to have_select("Privacy", selected: I18n.t("thread_privacy_options.group"))
      end
    end

    context "showing a thread" do
      before do
        visit group_thread_path(current_group, thread)
      end

      it "should show the thread title" do
        expect(page).to have_content(thread.title)
      end

      it "should have fields to create a new message" do
        expect(page).to have_field("Message")
      end
    end

    context "edit a thread" do
      before do
        visit group_thread_path(current_group, thread)
      end

      it "should let you edit the thread" do
        expect(page).to have_content(edit_thread)
        click_on edit_thread
        fill_in "Discussion title", with: "New, better, thread title"
        click_on "Save"
        expect(page).to have_content "Thread updated"
        expect(page).to have_content "New, better, thread title"
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
        expect(page).to have_select("Privacy", with_options: ["Group"])
        expect(page).not_to have_select("Privacy", with_options: ["Committee"])
      end
    end
  end

  context "thread deletion" do
    context "as an admin user" do
      include_context "signed in as admin"

      let(:group) { create(:group) }
      let(:thread) { create(:message_thread, group: group) }

      before do
        visit group_thread_path(group, thread)
      end

      it "should let you delete the thread" do
        click_on delete_thread
        expect(page).to have_content("Thread deleted")
        expect(page).not_to have_content(thread.title)
      end
    end
  end

  context "privacy" do
    let(:private_thread) { create(:group_private_message_thread, :with_messages) }

    context "as a guest" do
      it "should not show the private thread" do
        visit group_thread_path(private_thread.group, private_thread)
        expect(page).to have_content("You need to sign in or sign up before continuing.")
      end
    end

    context "as a signed in member" do
      include_context "signed in as a site user"

      it "should not show the private thread" do
        visit group_thread_path(private_thread.group, private_thread)
        expect(page).to have_content("You are not authorised to access that page.")
      end
    end

    context "as a member of the correct group" do
      include_context "signed in as a group member"

      let(:group_private_thread) { create(:group_private_message_thread, group: current_group) }

      it "should show the private thread" do
        visit group_thread_path(group_private_thread.group, group_private_thread)
        expect(page).to have_content(group_private_thread.title)
      end

      it "should not let you edit the thread" do
        expect(page).not_to have_content(edit_thread)
      end
    end

    context "as an admin" do
      include_context "signed in as admin"

      it "should let admins see any thread" do
        visit group_thread_path(private_thread.group, private_thread)
        expect(page).to have_content(private_thread.title)
      end
    end

    context "thread listing as a site user" do
      include_context "signed in as a site user"

      before do
        visit group_threads_path(private_thread.group)
      end

      it "should not show the title of private threads" do
        expect(page).not_to have_content(private_thread.title)
        expect(page).to have_content(I18n.t("decorators.thread_list.private_thread_title"))
      end

      it "should not show the last user who posted" do
        expect(page).not_to have_link(private_thread.latest_activity_by.name)
      end
    end
  end
end
