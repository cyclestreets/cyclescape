require "spec_helper"

describe MailboxCleaner do
  let(:config) do
    { host: "mail.example.com", user_name: "user@example.com", password: "secret",
      authentication: "PLAIN", mailbox: "INBOX", days_to_retain: 10 }
  end

  let(:imap) { double("IMAP connection") }

  describe "#search_query" do
    it "should search for seen messages" do
      subject.search_query(10).should include("SEEN")
    end

    it "should do a SENTBEFORE search based on days param" do
      subject.search_query(10).should include("SENTBEFORE")
      subject.search_query(10).last.should match(/[0-9]{2}-\w{3}-\d{4}/)
    end
  end

  describe "#delete_message" do
    it "should delete the message with given ID" do
      subject.stub(:imap).and_return(imap)
      imap.should_receive(:uid_store).with(31, "+FLAGS", [:Deleted])
      subject.delete_message(31)
    end
  end
end
