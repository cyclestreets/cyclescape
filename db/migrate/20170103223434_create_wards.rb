class CreateWards < ActiveRecord::Migration
  def change
    create_table :wards do |t|
      t.string :name
      t.geometry :location, srid: 4326, null: false
    end
    add_index :wards, :location, using: :gist

    sql = File.read(File.join(%w(db seeds Wards_December_2015_Super_Generalised_Clipped_Boundaries_in_Great_Britain.sql)))
    execute sql
    # make all the constituencies simple polygons http://stackoverflow.com/a/31863096
    update <<~DUMPSQL
      WITH dump AS (
        SELECT id, (ST_DUMP(location)).geom::geometry(Polygon,4326) as geometry FROM wards
      )
      UPDATE wards SET location = dump.geometry
      FROM dump
      WHERE wards.id = dump.id
    DUMPSQL
  end
end
