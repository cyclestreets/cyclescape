class RemoveNullConstrainOnUnserThreadPriorities < ActiveRecord::Migration
  def change
    change_column_null(:user_thread_priorities, :priority, true)
  end
end
