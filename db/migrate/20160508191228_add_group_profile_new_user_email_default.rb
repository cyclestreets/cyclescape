class AddGroupProfileNewUserEmailDefault < ActiveRecord::Migration
  def change
    select_rows(
      "SELECT group_profiles.id, groups.name, groups.short_name
       FROM group_profiles
       LEFT OUTER JOIN groups ON groups.id = group_profiles.group_id
       WHERE new_user_email IS NULL"
    ).each do |id, name, short_name|
      update(
        "UPDATE group_profiles
         SET new_user_email =
           #{quote("Hi {{full_name}},\n #{name} has added you to their Cyclescape group #{
             Rails.application.routes.url_helpers.root_url(
               subdomain: short_name, host: Rails.application.config.action_mailer.default_url_options[:host]
             )
            }.")}
         WHERE id = #{id}")
    end
    change_column_null :group_profiles, :new_user_email, false
  end
end
