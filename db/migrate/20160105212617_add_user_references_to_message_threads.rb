class AddUserReferencesToMessageThreads < ActiveRecord::Migration
  def change
    add_reference :message_threads, :user, index: true, foreign_key: true
  end
end
