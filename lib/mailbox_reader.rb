class MailboxReader
  def self.run
    mailboxes_config.each do |name, config|
      retriever = Mail::IMAP.new(config.symbolize_keys)
      retriever.find(what: :first).each do |message|
        mail = InboundMail.new_from_message(message)
        mail.save!
        Resque.enqueue(InboundMailProcessor, mail.id)
      end
    end
  end

  def self.mailboxes_config
    return @config if @config
    config_path = Rails.root + "config" + "mailboxes.yml"
    raise "Mailboxes config file not found at #{config_path}" unless config_path.exist?
    @config ||= YAML::load(File.read(config_path)).with_indifferent_access
  end
end
