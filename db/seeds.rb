# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create root user
unless User.where('id = 1').exists?
  root = User.new(email: 'root@cyclestreets.net', full_name: 'Root',
                  password: 'changeme', password_confirmation: 'changeme', role: 'admin', id: 1)
  root.skip_confirmation!
  root.save!
end

# Create some location categories
unless LocationCategory.count > 3
  ['Home', 'Work', 'Route to Work', 'School Ride', 'Weekend Ride', 'Other'].each do |cat|
    LocationCategory.new(name: cat).save!
  end
end

# Ensure all message threads have public tokens
MessageThread.where('public_token IS NULL').each do |thread|
  thread.set_public_token
  thread.save!
end

# Ensure all users have preferences
User.init_user_prefs

# Add icons to various tags, unless they have an icon set already
# Make sure the icon variations are in the assets folder when adding it here.
[{ name: 'parking', icon: 'cycle-parking' },
 { name: 'cycleparking', icon: 'cycle-parking' },
 { name: 'carparking', icon: 'car-parking' },
 { name: 'obstruction', icon: 'obstruction' },
 { name: 'planning', icon: 'planning' },
 { name: 'roadworks', icon: 'roadworks' },
 { name: 'path', icon: 'cycle-path' },
 { name: 'cyclepath', icon: 'cycle-path' },
 { name: 'council', icon: 'planning' },
 { name: 'gate', icon: 'obstruction' }].each do |t|
  tag = Tag.grab(t[:name])
  if tag.icon.blank?
    tag.icon = t[:icon]
    tag.save
  end
end
