require "net/imap"

class MailboxReader
  attr_accessor :config

  def self.process_all_mailboxes
    mailboxes_config.each do |name, config|
      reader = self.new(config)
      reader.run
    end
  end

  def self.mailboxes_config
    return @config if @config
    config_path = Rails.root + "config" + "mailboxes.yml"
    raise "Mailboxes config file not found at #{config_path}" unless config_path.exist?
    @config ||= YAML::load(File.read(config_path)).with_indifferent_access
  end

  def initialize(config = {})
    @config = config
  end

  def run
    begin
      fetch_message_ids(config[:mailbox]).each do |mid|
        # Fetch message from IMAP server
        message = fetch_raw_message(mid)
        # Save to database
        ar_message = save_message(message)
        # Mark message as read in IMAP mailbox
        mark_as_seen(mid)
        # Send to the mail processor
        enqueue(ar_message)
      end
    ensure
      disconnect
    end
  end

  def establish_connection
    @imap = Net::IMAP.new(config[:host])
    @imap.authenticate(config[:authentication], config[:user_name], config[:password])
    @imap
  end

  def imap
    @imap || establish_connection
  end

  def disconnect
    @imap.disconnect if @imap and not @imap.disconnected?
  end

  def fetch_message_ids(mailbox, search_command = "UNSEEN")
    imap.select(mailbox)
    imap.uid_search(Array(search_command))
  end

  def fetch_raw_message(uid)
    message_text = imap.uid_fetch(uid, ["RFC822"]).first.attr["RFC822"]
    # Mark message as unseen in case something goes wrong
    imap.uid_store(uid, "-FLAGS", [:Seen])
    message_text
  end

  def mark_as_seen(uid)
    imap.uid_store(uid, "+FLAGS", [:Seen])
  end

  def save_message(message)
    mail = Mail.new(message)
    record = InboundMail.new_from_message(mail)
    record.save!
    record
  end

  def enqueue(ar_message)
    processor = config[:mail_processor].constantize
    Resque.enqueue(processor, ar_message.id)
  end
end
