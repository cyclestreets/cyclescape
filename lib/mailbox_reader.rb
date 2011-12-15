require "net/imap"

class MailboxReader < MailboxProcessor
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
