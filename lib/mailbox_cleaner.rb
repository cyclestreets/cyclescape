class MailboxCleaner < MailboxProcessor
  def run
    begin
      ids = fetch_message_ids(config[:mailbox], search_query(config[:days_to_retain]))
      ids.each { |id| delete_message(id) }
      imap.close
    ensure
      disconnect
    end
  end

  def search_query(days_to_retain)
    date = Date.current - days_to_retain.days
    ["SEEN", "SENTBEFORE", date.strftime("%d-%b-%Y")]
  end

  def delete_message(uid)
    imap.uid_store(uid, "+FLAGS", [:Deleted])
  end
end
