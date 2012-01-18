class AddIconToTags < ActiveRecord::Migration
  def change
    add_column :tags, :icon, :string
  end
end
