class CreateSimpleHashtagHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags do |t|
      t.string :name, index: true
      t.references :group, index: true, foreign_key: true
      t.timestamps
    end
    add_index :hashtags, [:name, :group_id], unique: true
  end
end
