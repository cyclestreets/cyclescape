class AddMessageThreadsCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :message_threads_count, :integer
    Group.ids.each { |group_id| Group.reset_counters(group_id, :threads) }
  end
end
