# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create root user
unless User.where("id = 1").exists?
  root = User.new(email: "root@cyclestreets.net", full_name: "Root", role: "admin",
      password: "changeme", password_confirmation: "changeme")
  root.skip_confirmation!
  root.save!
  User.update_all("id = 1", "id = #{root.id}")
end

# Create some location categories
unless LocationCategory.count > 3
  ["Home", "Work", "Route to Work", "School Ride", "Weekend Ride", "Other"].each do |cat|
    LocationCategory.new(name: cat).save!
  end
end

# Ensure all message threads have public tokens
MessageThread.where("public_token IS NULL").each do |thread|
  thread.set_public_token
  thread.save!
end

# Ensure all users have preferences
User.init_user_prefs
