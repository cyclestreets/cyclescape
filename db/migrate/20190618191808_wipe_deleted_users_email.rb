class WipeDeletedUsersEmail < ActiveRecord::Migration[5.0]
  def change
    User.deleted.find_each do |usr|
      usr.tap(&:obfuscate_name).save!
    end
  end
end
