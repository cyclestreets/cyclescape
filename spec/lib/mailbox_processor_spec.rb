# frozen_string_literal: true

require "spec_helper"

describe MailboxProcessor do
  let(:config) do
    { host: "mail.example.com", user_name: "user@example.com", password: "secret",
      authentication: "PLAIN", mailbox: "INBOX", mail_processor: "MailProcessor" }
  end

  let(:imap) { double("IMAP connection") }

  describe "#establish_connection" do
    subject { MailboxProcessor.new(config) }

    before do
      allow(Net::IMAP).to receive(:new).and_return(imap)
      allow(imap).to receive(:authenticate).and_return(imap)
    end

    it "should connect to the given host" do
      expect(Net::IMAP).to receive(:new).with(config[:host])
      subject.establish_connection
    end

    it "should use the given connection details" do
      expect(imap).to receive(:authenticate).with(config[:authentication], config[:user_name], config[:password])
      subject.establish_connection
    end
  end

  describe "reading messages" do
    subject { MailboxProcessor.new(config) }

    describe "#fetch_message_ids" do
      before do
        allow(subject).to receive(:imap).and_return(imap)
        allow(imap).to receive(:select)
        allow(imap).to receive(:uid_search)
      end

      it "should access the given mailbox" do
        expect(imap).to receive(:select).with("MYMAIL")
        subject.fetch_message_ids("MYMAIL")
      end

      it "should search for unseen messages by default" do
        expect(imap).to receive(:uid_search).with(["UNSEEN"])
        subject.fetch_message_ids("MYMAIL")
      end

      it "should return the search results" do
        expect(imap).to receive(:uid_search).and_return(:results)
        expect(subject.fetch_message_ids("MYMAIL")).to eq(:results)
      end
    end

    describe "#fetch_message" do
      let(:message) { double("message", attr: { "RFC822" => "Mail text" }) }

      before do
        allow(subject).to receive(:imap).and_return(imap)
        allow(imap).to receive(:uid_fetch).and_return([message])
        allow(imap).to receive(:uid_store)
      end

      it "should fetch the given message and ask for RFC822 format" do
        expect(imap).to receive(:uid_fetch).with(31, ["RFC822"])
        subject.fetch_raw_message(31)
      end

      it "should unset the seen flag" do
        expect(imap).to receive(:uid_store).with(31, "-FLAGS", [:Seen])
        subject.fetch_raw_message(31)
      end

      it "should return the message text" do
        expect(subject.fetch_raw_message(31)).to eq("Mail text")
      end
    end
  end
end
