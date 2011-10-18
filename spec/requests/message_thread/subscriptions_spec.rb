require "spec_helper"

describe "Thread subscriptions" do
  let(:thread) { FactoryGirl.create(:message_thread) }

  context "site user subscribe", as: :site_user do
    before do
      visit thread_path(thread)
    end

    it "should subscribe the user to the thread" do
      click_on "Subscribe"
      page.should have_content("Subscription created.")
      current_user.thread_subscriptions.count.should == 1
      current_user.thread_subscriptions.first.thread.should == thread
    end

    it "should send a notification confirming the subscription"
    it "should send future messages on the thread by email"
  end
end
