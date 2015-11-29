class AddAllDayToDeadlineMessagesAndIssues < ActiveRecord::Migration
  def change
    add_column :deadline_messages, :all_day, :boolean, default: false, null: false
    add_column :issues, :all_day, :boolean, default: false, null: false

    #Default is false in future but was true
    update "UPDATE deadline_messages SET all_day = #{quoted_true}"
    update "UPDATE issues SET all_day = #{quoted_true}"
  end
end
