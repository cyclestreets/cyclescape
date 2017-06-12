# This migration comes from simple_hashtag
class CreateSimpleHashtagHashtaggings < ActiveRecord::Migration
  def change
    create_table :hashtaggings do |t|
      t.references :hashtag, index: true, foreign_key: true
      t.references :message, index: true, foreign_key: true
    end
    add_index :hashtaggings, [:hashtag_id, :message_id]
  end
end
