# frozen_string_literal: true

require "net/imap"

class MailboxProcessor
  attr_accessor :config

  def initialize(config)
    @config = config
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
    @imap.disconnect if @imap && !@imap.disconnected?
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
end
