class RenameInboundMailsMessageColumn < ActiveRecord::Migration
  def up
    rename_column :inbound_mails, :message, :raw_message
  end

  def down
    rename_column :inbound_mails, :raw_message, :message
  end
end
