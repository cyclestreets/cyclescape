class RelaxApprovedOnUsers < ActiveRecord::Migration
  def change
    users_in_groups = select_rows "SELECT user_id FROM group_memberships"
    update "UPDATE users
            SET approved = #{quoted_true}
            WHERE id IN (#{users_in_groups.join(', ')})
            AND disabled_at IS NULL
            AND deleted_at IS NULL"
  end
end
