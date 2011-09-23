class AddLocationToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :location, :geometry, :srid => 4326
  end
end
