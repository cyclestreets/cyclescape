class CreateIssueTagsJoinTable < ActiveRecord::Migration
  def up
    create_table :issue_tags, id: false do |t|
      t.integer :issue_id, null: false
      t.integer :tag_id, null: false
    end

    add_index :issue_tags, [:issue_id, :tag_id], unique: true
  end

  def down
    drop_table :issue_tags
  end
end
