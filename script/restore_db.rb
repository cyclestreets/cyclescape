# Run using
# `ruby script/restore_db.rb CS_SSH_USERNAME`
# where CS_SSH_USERNAME is your cyclescape ssh username

`scp #{ARGV.first}@cyclescape.org:/websites/cyclescape/backup/cyclescapeDB.sql.gz .`
`gunzip cyclescapeDB.sql.gz`
unless system "bundle exec rake db:drop db:create"
  puts "Cannot drop and recreate database, existing"
  exit 1
end
if system "psql -U postgres cyclescape_development < cyclescapeDB.sql"
  `rake anon_db:anon`
  `rm cyclescapeDB.sql`
end
