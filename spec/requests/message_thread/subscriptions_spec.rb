require "spec_helper"

describe "Thread subscriptions" do
  let(:thread) { FactoryGirl.create(:message_thread) }

  context "site user subscribe" do
    include_context "signed in as a site user"

    before do
      visit thread_path(thread)
    end

    context "for web" do
      it "should subscribe the user to the thread" do
        click_on "Subscribe"
        page.should have_content("Subscription created.")
        current_user.thread_subscriptions.count.should == 1
        current_user.thread_subscriptions.first.thread.should == thread
        current_user.thread_subscriptions.first.send_email.should be_false
      end

      it "should state I am subscribed" do
        click_on "Subscribe"
        page.should have_content("You are subscribed")
      end
    end

    context "for email" do
      it "should subscribe the user to the thread" do
        check "Send new messages to me by email"
        click_on "Subscribe"
        page.should have_content("Subscription created.")
        current_user.thread_subscriptions.count.should == 1
        current_user.thread_subscriptions.first.thread.should == thread
        current_user.thread_subscriptions.first.send_email.should be_true
      end

      it "should send future messages on the thread by email" do
        check "Send new messages to me by email"
        click_on "Subscribe"
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
        check "Send new messages to me by email"
        click_on "Subscribe"
        page.should have_content("You are subscribed by email")
      end
    end

    context "cancelling" do
      before do
        click_on "Subscribe"
      end

      it "should unsubscribe me" do
        current_user.should have(1).thread_subscription
        click_on "Unsubscribe"
        current_user.should have(0).thread_subscriptions
        page.should have_content("Unsubscribed")
      end

      it "should not send me any more messages" do
        email_count = all_emails.count
        click_on "Unsubscribe"
        within(".new-message") do
          fill_in "Message", with: "Notification test"
          click_on "Post Message"
        end
        email_count.should == all_emails.count
      end
    end
  end
end
