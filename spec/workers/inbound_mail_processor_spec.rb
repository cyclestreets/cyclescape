require "spec_helper"

describe InboundMailProcessor do
  subject { InboundMailProcessor }

  it "should be on the inbound mail queue" do
    subject.queue.should == :inbound_mail
  end

  it "should respond to perform" do
    subject.should respond_to(:perform)
  end

  context "thread reply mail" do
    let(:thread) { FactoryGirl.create(:message_thread) }
    let(:email_recipient) { "thread-#{thread.public_token}@cyclescape.org" }
    let(:inbound_mail) { FactoryGirl.create(:inbound_mail, to: email_recipient) }

    context "message" do
      before do
        subject.perform(inbound_mail.id)
      end

      it "should create a new message on the thread" do
        thread.should have(1).message
      end

      it "should have the same text as the email" do
        # There are weird newline issues here, each \r is duplicated in the model's response
        thread.messages.first.body.gsub(/\n|\r/, '').should == inbound_mail.message.body.to_s.gsub(/\n|\r/, '')
      end

      it "should have be created by a new user with the email address" do
        thread.messages.first.created_by.email.should == inbound_mail.message.from.first
      end
    end

    context "notifications" do
      it "should be sent out" do
        ThreadNotifier.should_receive(:notify_subscribers) do |thread, type, message|
          thread.should be_a(MessageThread)
          type.should == :new_message
          message.should be_a(Message)
        end
        subject.perform(inbound_mail.id)
      end
    end
  end
end
