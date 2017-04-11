class AddAuthorityParamToPlanningApplications < ActiveRecord::Migration
  def change
    add_column :planning_applications, :authority_param, :string
    rows = select_all <<-SQL
      SELECT id, authority_name
      FROM planning_applications
      ORDER BY id
    SQL

    return if rows.blank?

    grouped = rows.group_by { |row| row.values_at("authority_name") }.values.each do |las|
      ids = las.map { |la| la["id"] }.join(', ')
      authority_param = las[0]["authority_name"].parameterize

      update <<-SQL
        UPDATE planning_applications
        SET authority_param = '#{authority_param}'
        WHERE id in (#{ids})
      SQL
    end

    remove_index :planning_applications, [:uid]
    add_index :planning_applications, [:uid, :authority_param], unique: true
  end
end
