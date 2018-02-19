require 'net/imap'

class MailboxReader < MailboxProcessor
  def run
    fetch_message_ids(config[:mailbox]).each do |mid|
      begin
        # Fetch message from IMAP server
        message = fetch_raw_message(mid)
        # Save to database
        ar_message = save_message(message)
        # Send to the mail processor
        enqueue(ar_message)
      ensure
        # Mark message as read in IMAP mailbox
        mark_as_seen(mid)
      end
    end
  ensure
    disconnect
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
