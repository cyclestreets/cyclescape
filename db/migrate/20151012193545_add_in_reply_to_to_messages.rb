class AddInReplyToToMessages < ActiveRecord::Migration
  def change
    add_reference :messages, :in_reply_to, index: true
  end
end
