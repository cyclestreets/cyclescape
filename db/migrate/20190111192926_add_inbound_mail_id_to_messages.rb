class AddInboundMailIdToMessages < ActiveRecord::Migration
  def change
    add_reference :messages, :inbound_mail, index: false, foreign_key: true
  end
end
