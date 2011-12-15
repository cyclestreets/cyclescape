require "spec_helper"

MailProcessor = nil

describe MailboxReader do
  let(:config) do
    {host: "mail.example.com", user_name: "user@example.com", password: "secret",
      authentication: "PLAIN", mailbox: "INBOX", mail_processor: "MailProcessor"}
  end

  let(:imap) { double("IMAP connection") }

  describe "#establish_connection" do
    subject { MailboxReader.new(config) }

    before do
      Net::IMAP.stub!(:new).and_return(imap)
      imap.stub!(:authenticate).and_return(imap)
    end

    it "should connect to the given host" do
      Net::IMAP.should_receive(:new).with(config[:host])
      subject.establish_connection
    end
      
    it "should use the given connection details" do
      imap.should_receive(:authenticate).with(config[:authentication], config[:user_name], config[:password])
      subject.establish_connection
    end
  end

  describe "reading messages" do
    subject { MailboxReader.new(config) }

    describe "#fetch_message_ids" do
      before do
        subject.stub!(:imap).and_return(imap)
        imap.stub!(:select)
        imap.stub!(:uid_search)
      end
        
      it "should access the given mailbox" do
        imap.should_receive(:select).with("MYMAIL")
        subject.fetch_message_ids("MYMAIL")
      end

      it "should search for unseen messages by default" do
        imap.should_receive(:uid_search).with(["UNSEEN"])
        subject.fetch_message_ids("MYMAIL")
      end

      it "should return the search results" do
        imap.should_receive(:uid_search).and_return(:results)
        subject.fetch_message_ids("MYMAIL").should == :results
      end
    end

    describe "#fetch_message" do
      let(:message) { message = double("message", attr: {"RFC822" => "Mail text"}) }

      before do
        subject.stub!(:imap).and_return(imap)
        imap.stub!(:uid_fetch).and_return([message])
        imap.stub!(:uid_store)
      end

      it "should fetch the given message and ask for RFC822 format" do
        imap.should_receive(:uid_fetch).with(31, ["RFC822"])
        subject.fetch_raw_message(31)
      end

      it "should unset the seen flag" do
        imap.should_receive(:uid_store).with(31, "-FLAGS", [:Seen])
        subject.fetch_raw_message(31)
      end

      it "should return the message text" do
        subject.fetch_raw_message(31).should == "Mail text"
      end
    end
  end

  describe "saving messages" do
    subject { MailboxReader.new(config) }
    let(:message) { File.read(raw_email_path) }

    describe "#save_message" do
      it "should create a saved record from the raw message" do
        record = double
        record.should_receive(:save!)
        InboundMail.should_receive(:new_from_message) do |arg|
          arg.should be_instance_of Mail::Message
          record
        end
        subject.save_message(message).should == record
      end
    end

    describe "#enqueue" do
      let(:record) { double(id: 31) }

      it "should use the configured mail processor" do
        Resque.should_receive(:enqueue).with(MailProcessor, anything)
        subject.enqueue(record)
      end

      it "should send the message ID" do
        Resque.should_receive(:enqueue).with(anything, 31)
        subject.enqueue(record)
      end
    end
  end
end
