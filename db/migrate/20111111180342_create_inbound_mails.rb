class CreateInboundMails < ActiveRecord::Migration
  def change
    create_table :inbound_mails do |t|
      t.string :recipient, null: false
      t.text :message, null: false
      t.datetime :created_at, null: false
      t.datetime :processed_at
      t.boolean :process_error, null: false, default: false
    end
  end
end
