require 'spec_helper'

describe 'Thread subscriptions' do
  let(:thread) { create(:message_thread_with_messages) }
  let(:subscribe_button) { find_button(I18n.t('formtastic.actions.thread_subscription.create')) }

  context 'site user subscribe' do
    include_context 'signed in as a site user'

    before do
      visit thread_path(thread)
    end

    context 'for web only' do
      before do
        current_user.prefs.update_column(:email_status_id, 0)
      end

      it 'should subscribe the user to the thread' do
        subscribe_button.click
        expect(page).to have_content('You are now subscribed to this thread')
        expect(current_user.thread_subscriptions.count).to eq(1)
        expect(current_user.thread_subscriptions.first.thread).to eq(thread)
      end

      it 'should state I am subscribed' do
        subscribe_button.click
        expect(page).to have_content(I18n.t('.message_threads.subscribe_panel.subscribed'))
      end

      it 'should not send me an email when I post' do
        email_count = all_emails.count
        subscribe_button.click
        within('.new-message') do
          fill_in 'Message', with: "All interesting stuff, but don't email me", match: :first
          click_on 'Post Message'
        end
        expect(all_emails.count).to eq(email_count)
      end

      context 'automatically' do
        it 'should subscribe me when I post a message' do
          expect(current_user.subscribed_to_thread?(thread)).to be_falsey
          within('.new-message') do
            fill_in 'Message', with: "Given I'm interested enough to post, I should be subscribed", match: :first
            click_on 'Post Message'
          end
          expect(current_user.subscribed_to_thread?(thread)).to be_truthy
        end

        # check some of the other message types too.
        it 'should subscribe me when I post a deadline' do
          expect(current_user.subscribed_to_thread?(thread)).to be_falsey
          within('#new-deadline-message') do
            fill_in 'Deadline', with: Date.current.to_s
            fill_in 'Title', with: 'Submission deadline'
            click_on I18n.t('message.deadlines.new.submit')
          end
          expect(current_user.subscribed_to_thread?(thread)).to be_truthy
        end

        it 'should subscribe me when I post a photo' do
          expect(current_user.subscribed_to_thread?(thread)).to be_falsey
          within('#new-photo-message') do
            attach_file('Photo', abstract_image_path)
            fill_in 'Caption', with: 'An abstract image'
            click_on 'Add Photo'
          end
          expect(current_user.subscribed_to_thread?(thread)).to be_truthy
        end
      end
    end

    context 'for email' do
      before do
        # Set the user to receive emails
        current_user.prefs.update_column(:email_status_id, 1)
      end

      it 'should subscribe the user to the thread' do
        subscribe_button.click
        expect(page).to have_content('You are now subscribed to this thread')
        expect(current_user.thread_subscriptions.count).to eq(1)
        expect(current_user.thread_subscriptions.first.thread).to eq(thread)
      end

      it 'should send future messages on the thread by email' do
        subscribe_button.click
        within('.new-message') do
          fill_in 'Message', with: 'Notification test', match: :first
          click_on 'Post Message'
        end
        message = Message.find_by(body: 'Notification test')
        open_email(current_user.email, with_subject: /^Re/)
        expect(current_email).to have_subject("Re: [Cyclescape] #{thread.title}")
        expect(current_email).to have_body_text(/Notification test/)
        expect(current_email).to be_delivered_from("#{current_user.name} <notifications@cyclescape.org>")
        expect(current_email).to have_reply_to("Cyclescape <message-#{message.public_token}@cyclescape.org>")
      end
    end

    context 'cancelling' do
      let(:unsubscribe_button) { find_button('Unfollow') }

      before do
        subscribe_button.click
      end

      it 'should unsubscribe me' do
        expect(current_user).to be_subscribed_to_thread(thread)
        unsubscribe_button.click
        expect(current_user).not_to be_subscribed_to_thread(thread)
        expect(page).to have_content('You have unsubscribed from this thread')
      end

      it 'should not send me any more messages' do
        email_count = all_emails.count
        unsubscribe_button.click
        within('.new-message') do
          fill_in 'Message', with: 'Notification test', match: :first
          click_on 'Post Message'
        end
        expect(all_emails.count).to eq(email_count)
      end

      it 'should resubscribe me' do
        expect(current_user).to be_subscribed_to_thread(thread)
        unsubscribe_button.click
        expect(current_user).not_to be_subscribed_to_thread(thread)
        subscribe_button.click
        expect(current_user).to be_subscribed_to_thread(thread)
      end
    end
  end

  context 'to private threads' do
    # These checks involve detecting faked post data, where someone is trying to
    # subscribe to threads that they don't have access to view.

    def attempt_subscription(t)
      page.driver.post thread_subscriptions_path(t)
      t.reload
    end

    context 'as a site user' do
      include_context 'signed in as a site user'

      let(:public_thread) { create(:thread) }
      let(:private_thread) { create(:group_private_message_thread) }
      let(:committee_thread) { create(:group_committee_message_thread) }

      # First, prove the positive case. Use this as a template.
      it 'should let you subscribe to a public thread' do
        expect(thread.subscribers).not_to include(current_user)
        attempt_subscription(thread)
        expect(thread.subscribers).to include(current_user)
      end

      it 'should not let a site member subscribe to a private thread' do
        attempt_subscription(private_thread)
        expect(private_thread.subscribers).not_to include(current_user)
      end

      it 'should not let a site member subscribe to a committee thread' do
        attempt_subscription(committee_thread)
        expect(committee_thread.subscribers).not_to include(current_user)
      end
    end

    context 'as a group member' do
      include_context 'signed in as a group member'

      let(:private_thread) { create(:group_private_message_thread, group: current_group) }
      let(:committee_thread) { create(:group_committee_message_thread, group: current_group) }

      it 'should let a group member subscribe to a private thread' do
        attempt_subscription(private_thread)
        expect(private_thread.subscribers).to include(current_user)
      end

      it 'should not let a group member subscribe to a committee thread' do
        attempt_subscription(committee_thread)
        expect(committee_thread.subscribers).not_to include(current_user)
      end
    end
  end
end
