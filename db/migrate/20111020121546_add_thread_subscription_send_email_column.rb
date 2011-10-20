class AddThreadSubscriptionSendEmailColumn < ActiveRecord::Migration
  def up
    add_column :thread_subscriptions, :send_email, :boolean, null: false, default: false
  end

  def down
    remove_column :thread_subscriptions, :send_email
  end
end
