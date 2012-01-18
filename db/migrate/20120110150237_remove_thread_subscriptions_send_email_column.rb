class RemoveThreadSubscriptionsSendEmailColumn < ActiveRecord::Migration
  def up
    remove_column :thread_subscriptions, :send_email
  end

  def down
    add_column :thread_subscriptions, :send_email, :boolean, null: false, default: false
  end
end
