class CreateConstituencies < ActiveRecord::Migration
  def up
    create_table :constituencies do |t|
      t.string :name
      t.geometry :location, srid: 4326, null: false
    end

    add_index :constituencies, :location, using: :gist
    # in ZSH (change the >! in BASH)
    # shp2pgsql -s 27700:4326 -a Westminster_Parliamentary_Constituencies_December_2015_Ultra_Generalised_Clipped_Boundaries_in_Great_Britain.shp constituencies | sed "s/'.*'\([A-Z]\)/'\1/g" | sed 's/"objectid","pcon15cd","pcon15nm","st_areasha","st_lengths",geom/name,location/' | sed "s/,'.*ST_T/,ST_T/" >! Westminster_Parliamentary_Constituencies_December_2015_Ultra_Generalised_Clipped_Boundaries_in_Great_Britain.sql
    sql = File.read(File.join(%w(db seeds Westminster_Parliamentary_Constituencies_December_2015_Ultra_Generalised_Clipped_Boundaries_in_Great_Britain.sql)))
    execute sql
    update "UPDATE constituencies SET location = (ST_DUMP(location)).geom::geometry(Polygon,4326)" # make all the constituencies simple polygons http://stackoverflow.com/a/31863096
  end

  def down
    drop_table :constituencies
  end
end
