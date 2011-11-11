class MailboxReader
  def self.run
    mailboxes_config.each do |name, config|
      retriever = Mail::IMAP.new(config)
      retriever.find_and_delete(what: :first).each do |message|
        mail = InboundMail.new_from_message(message)
        mail.save!
      end
    end
  end

  def self.mailboxes_config
    @config ||= YAML::load(File.read(Rails.root + "config" + "mailboxes.yml"))
  end
end
