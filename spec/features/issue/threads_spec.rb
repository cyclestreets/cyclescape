require 'spec_helper'

describe 'Issue threads' do
  let!(:issue) { create(:issue) }
  let(:issue_with_tags) { create(:issue, :with_tags) }
  let(:edit_thread) { 'Edit this thread' }

  context 'new' do
    context 'as a site user' do
      include_context 'signed in as a site user'

      it 'should create a new public thread' do
        visit issue_path(issue)
        click_on 'Discuss'
        fill_in 'Message', with: 'Awesome!'
        click_on 'Create Thread'
        expect(page).to have_content(issue.title)
        expect(page).to have_content('Awesome!')
        expect(current_user.subscribed_to_thread?(issue.threads.last)).to be_truthy
      end

      it 'should pre-fill the title for the thread' do
        visit issue_path(issue)
        click_on 'Discuss'
        expect(find_field('Discussion title').value).to eq(issue.title)
      end

      it 'should not pre-fill the title for the second thread' do
        visit issue_path(issue)
        click_on 'Discuss'
        fill_in 'Message', with: 'Awesome!'
        click_on 'Create Thread'
        visit issue_path(issue)
        click_on 'New Thread'
        expect(find_field('Discussion title').value).to be_nil
      end

      it 'should copy the tags from the issue' do
        visit issue_path(issue_with_tags)
        click_on 'Discuss'
        fill_in 'Message', with: 'Foo'
        click_on 'Create Thread'
        expect(MessageThread.last.tags.length).to be > 0
      end
    end

    context 'as a group member' do
      include_context 'signed in as a group member'

      it 'should still create a new public thread' do
        visit issue_path(issue)
        click_on 'Discuss'
        fill_in 'Message', with: 'Awesome!'
        click_on 'Create Thread'
        expect(page).to have_content(issue.title)
        expect(page).to have_content('Awesome!')
        expect(page).to have_content('Public: Everyone can view this thread and post messages.')
      end

      it 'should create a new public group thread' do
        visit issue_path(issue)
        click_on 'Discuss'
        select current_group.name, from: 'Owned by'
        fill_in 'Message', with: 'Awesome!'
        select 'Public', from: 'Privacy'
        click_on 'Create Thread'
        expect(page).to have_content(issue.title)
        expect(page).to have_content('Awesome!')
        expect(page).to have_content('Public: Everyone can view this thread and post messages.')
      end

      it 'should create a new private group thread' do
        visit issue_path(issue)
        click_on 'Discuss'
        select current_group.name, from: 'Owned by'
        fill_in 'Message', with: 'Awesome!'
        select 'Group', from: 'Privacy'
        click_on 'Create Thread'
        expect(page).to have_content(issue.title)
        expect(page).to have_content('Awesome!')
        expect(page).to have_content("Private: Only members of #{current_group.name} can view and post messages to this thread.")
      end

      context 'in a subdomain', use: :current_subdomain do
        it 'should default to be owned by the current group' do
          visit issue_path(issue)
          click_on 'Discuss'
          # Done twice so it's clear what's failing, as the error is confusing
          expect(page).to have_select('Owned by')
          expect(page).to have_select('Owned by', selected: current_group.name)
        end

        it "should default to the group's privacy setting" do
          current_group.update_column(:default_thread_privacy, 'group')
          visit issue_path(issue)
          click_on 'Discuss'
          expect(page).to have_select('Privacy')
          expect(find_field('Privacy').value).to eq('group')
        end
      end

      context 'group thread notification' do
        let(:user) { create(:user) }
        # Non-conflicting name
        let(:group_membership) { create(:group_membership, group: current_group, user: user) }
        let(:notifiee) { group_membership.user }

        before do
          notifiee.prefs.update_column(:involve_my_groups, 'notify')
          notifiee.prefs.update_column(:email_status_id, 1)
          reset_mailer
        end

        def create_thread
          message = SecureRandom.hex
          visit issue_path(issue)
          click_on 'Discuss'
          select current_group.name, from: 'Owned by'
          fill_in 'Message', with: message
          click_on 'Create Thread'
          message
        end

        it 'should be sent to other group members' do
          message_body = create_thread
          open_last_email_for(notifiee.email)
          message = Message.find_by(body: message_body)
          expect(current_email).to have_subject("[Cyclescape] \"#{issue.title}\" (#{current_group.name})")
          expect(current_email).to be_delivered_from("#{current_user.name} <notifications@cyclescape.org>")
          expect(current_email.header[:reply_to].addrs.first.to_s).to include("message-#{message.public_token}@cyclescape.org")
        end

        context 'with an unconfirmed user' do
          let(:user) { create(:user, :unconfirmed) }

          it 'should not receive it' do
            create_thread
            email = open_last_email_for(notifiee.email)
            expect(email).to be_nil
          end
        end
      end
    end

    context 'user locations notifications' do
      # when a thread is created on an issue, and that issue overlaps a users locations, send notifications

      include_context 'signed in as a group member'

      let(:notifiee) { create(:user) }
      let!(:notifiee_location_big) { create(:user_location, user: notifiee, location: issue.location.buffer(1)) }
      let!(:user_location) { create(:user_location, user: current_user, location: issue.location.buffer(1)) }

      before do
        current_user.prefs.update_column(:involve_my_groups, 'none')
        notifiee.prefs.update_column(:involve_my_locations, 'notify')
        notifiee.prefs.update_column(:email_status_id, 1)
        reset_mailer
      end

      def create_thread
        message = "<p>#{SecureRandom.hex}</p>"
        visit issue_path(issue)
        click_on 'Discuss'
        fill_in 'Discussion title', with: 'Lorem & Ipsum'
        fill_in 'Message', with: message
        click_on 'Create Thread'
        message
      end

      it 'should send a notification' do
        message_body = create_thread
        email = open_last_email_for(notifiee.email)
        message = Message.find_by(body: message_body)

        expect(email).to have_subject("[Cyclescape] New thread started on issue \"#{issue.title}\"")
        expect(email).to have_body_text(issue.title)
        expect(email).to have_body_text('Lorem & Ipsum')
        expect(email.html_part.decoded).to include(message_body)
        expect(email).to have_body_text(current_user.name)
        expect(email).to be_delivered_from("#{current_user.name} <notifications@cyclescape.org>")
        expect(current_email.header[:reply_to].addrs.first.to_s).to include("message-#{message.public_token}@cyclescape.org")
      end

      it 'should not send multiple notifications to the same person' do
        email_count = all_emails.count
        create_thread
        expect(all_emails.count).to eql(email_count + 1)
      end

      it "should not send a notification if they don't have permission to view the thread" do
        visit issue_path(issue)
        click_on 'Discuss'
        fill_in 'Discussion title', with: 'Super secrets'
        select current_group.name, from: 'Owned by'
        select 'Group', from: 'Privacy'
        fill_in 'Message', with: "Don't tell anyone, but..."

        email_count = all_emails.count
        click_on 'Create Thread'
        expect(all_emails.count).to eql(email_count)

        email = open_last_email_for(notifiee.email)
        expect(email).to be_nil
      end

      it 'should send a new message notification to the person who started the thread' do
        current_user.prefs.update_column(:involve_my_locations, 'notify')
        current_user.prefs.update_column(:email_status_id, 1)
        create_thread

        mailbox = mailbox_for(current_user.email)
        expect(mailbox.count).to eql(1)
        email = mailbox.last

        # The sender should receive a message notification, not a new thread notification
        expect(email).not_to have_subject(/New thread started/)
        expect(email).to have_subject('[Cyclescape] Lorem & Ipsum') # first message, so no Re:
      end

      it 'should send a new message notification to anyone who is auto-subscribed to the thread' do
        notifiee.prefs.update_column(:involve_my_locations, 'subscribe')
        create_thread

        mailbox = mailbox_for(notifiee.email)
        expect(mailbox.count).to eql(1)
        email = mailbox.last
        expect(email).to have_subject('[Cyclescape] Lorem & Ipsum')
      end
    end

    context 'automatic subscriptions' do
      include_context 'signed in as a site user'

      def create_thread
        visit issue_path(issue)
        click_on 'Discuss'
        fill_in 'Discussion title', with: 'Lorem & Ipsum'
        fill_in 'Message', with: 'Something or other'
        click_on 'Create Thread'
      end

      context "with a potential subscriber" do
        let(:subscriber) { subscriber_location.user }
        let!(:subscriber_location) { create(:user_location, location: issue.location.buffer(1)) }

        it 'should not subscribe when the preference is not set' do
          subscriber.prefs.update_column(:involve_my_locations, 'notify')
          create_thread
          expect(subscriber.subscribed_to_thread?(issue.threads.last)).to be_falsey
        end

        context "with a disabled user" do
          let(:disabled_subscriber) { create(:user, disabled_at: Time.current) }
          let!(:disabled_subscriber_location) do
            create(:user_location, user: disabled_subscriber, location: issue.location.buffer(1))
          end

          it 'should automatically subscribe non-disabled users with overlapping locations' do
            create_thread
            expect(subscriber.subscribed_to_thread?(issue.threads.last)).to be_truthy
            expect(disabled_subscriber.subscribed_to_thread?(issue.threads.last)).to be_falsey
          end
        end
      end

      it 'should only subscribe the thread creator once' do
        create(:user_location, user: current_user, location: issue.location.buffer(1))
        create_thread
        expect(current_user.thread_subscriptions.count).to eq(1)
      end
    end
  end

  context 'edit' do
    let(:thread) { create(:message_thread, issue: issue, group: current_group) }

    context 'as a group member' do
      include_context 'signed in as a group member'

      it 'should not let you' do
        visit issue_thread_path(issue, thread)
        expect(page).to have_content(issue.title)
        expect(page).to have_content(thread.title)
        expect(page).not_to have_content(edit_thread)
      end
    end

    context 'as a group committee member' do
      include_context 'signed in as a committee member'

      it 'should let you edit the thread' do
        visit issue_thread_path(issue, thread)
        click_on edit_thread
        fill_in I18n.t("activerecord.attributes.message_thread.title"), with: 'New title please'
        click_on 'Save'
        expect(page).to have_content('Thread updated')
        expect(page).to have_content('New title please')
      end
    end
  end

  context 'group private thread' do
    let!(:thread) { create(:group_private_message_thread_with_messages, issue: issue) }
    context 'as an admin' do
      include_context 'signed in as admin'

      it 'should show you a link to the thread' do
        visit issue_path(issue)
        expect(page).to have_content(thread.title)
        expect(page).to have_content('Group Private')
        expect(page).to have_link(thread.title)
      end
    end
  end

  context 'when showing' do
    context 'a non-group public thread in a subdomain', use: :current_subdomain do
      include_context 'signed in as a group member'

      let!(:thread) { create(:message_thread_with_messages, issue: issue) }

      it 'should be accessible' do
        visit issue_path(issue)
        click_on thread.title
        expect(page).to have_content(thread.title)
      end
    end
  end
end
