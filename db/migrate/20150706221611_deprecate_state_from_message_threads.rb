class DeprecateStateFromMessageThreads < ActiveRecord::Migration
  def change
    change_column_null :message_threads, :state, true
    rename_column :message_threads, :state, :zzz_state
  end
end
