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
      end

      it "should send a notification confirming the subscription" do
        click_on "Subscribe"
        open_email(current_user.email)
        current_email.should have_subject("Subscribed to \"#{thread.title}\"")
        current_email.should have_body_text(/#{current_user.name}/)
        current_email.should have_body_text(/You have subscribed to "#{thread.title}"/)
      end
    end

    context "for email" do
      it "should subscribe the user to the thread" do
        click_on "Subscribe"
        page.should have_content("Subscription created.")
        current_user.thread_subscriptions.count.should == 1
        current_user.thread_subscriptions.first.thread.should == thread
        current_user.thread_subscriptions.format.should == "email"
      end

      it "should send future messages on the thread by email" do
        click_on "Subscribe"
        within(".new-message") do
          fill_in "Message", with: "Notification test"
          click_on "Post Message"
        end
        open_email(current_user.email)
        current_email.should have_subject("Re: #{thread.title}")
        current_email.should have_body_text(/Notification test/)
      end
    end
  end
end
