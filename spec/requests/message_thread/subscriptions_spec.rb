require "spec_helper"

describe "Thread subscriptions" do
  let(:thread) { FactoryGirl.create(:message_thread) }
  let(:subscribe_by_email_field) { I18n.t("formtastic.labels.thread_subscription.send_email") }
  let(:subscribe_button) { find_button(I18n.t("formtastic.actions.thread_subscription.create")) }

  context "site user subscribe" do
    include_context "signed in as a site user"

    before do
      visit thread_path(thread)
    end

    context "for web" do
      it "should subscribe the user to the thread" do
        subscribe_button.click
        page.should have_content("You are now subscribed to this thread.")
        current_user.thread_subscriptions.count.should == 1
        current_user.thread_subscriptions.first.thread.should == thread
        current_user.thread_subscriptions.first.send_email.should be_false
      end

      it "should state I am subscribed" do
        subscribe_button.click
        page.should have_content("You are subscribed")
      end

      it "should not send me an email when I post" do
        email_count = all_emails.count
        subscribe_button.click
        within(".new-message") do
          fill_in "Message", with: "All interesting stuff, but don't email me"
          click_on "Post Message"
        end
        all_emails.count.should == email_count
      end
    end

    context "for email" do
      it "should subscribe the user to the thread" do
        check subscribe_by_email_field
        subscribe_button.click
        page.should have_content("You are now subscribed to this thread.")
        current_user.thread_subscriptions.count.should == 1
        current_user.thread_subscriptions.first.thread.should == thread
        current_user.thread_subscriptions.first.send_email.should be_true
      end

      it "should send future messages on the thread by email" do
        check subscribe_by_email_field
        subscribe_button.click
        within(".new-message") do
          fill_in "Message", with: "Notification test"
          click_on "Post Message"
        end
        open_email(current_user.email, with_subject: /^Re/)
        current_email.should have_subject("Re: #{thread.title}")
        current_email.should have_body_text(/Notification test/)
        current_email.should be_delivered_from("Cyclescape <thread-#{thread.public_token}@cyclescape.org>")
      end

      it "should state I am subscribed by email" do
        check subscribe_by_email_field
        subscribe_button.click
        page.should have_content("You are subscribed by email")
      end
    end

    context "cancelling" do
      let(:unsubscribe_button) { find_button("Unfollow") }

      before do
        subscribe_button.click
      end

      it "should unsubscribe me" do
        current_user.should have(1).thread_subscription
        unsubscribe_button.click
        current_user.should have(0).thread_subscriptions
        page.should have_content("You have unsubscribed from this thread.")
      end

      it "should not send me any more messages" do
        email_count = all_emails.count
        unsubscribe_button.click
        within(".new-message") do
          fill_in "Message", with: "Notification test"
          click_on "Post Message"
        end
        all_emails.count.should == email_count
      end
    end
  end
end
