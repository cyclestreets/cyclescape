namespace 'anon_db' do
  desc 'Anonymise the database'
  task anon: :environment do
    User.find_each.with_index do |usr, idx|
      next if usr.role == "admin"
      usr.update_columns(email: "not#{idx}@my.email", full_name: "User #{usr.id}")
    end
  end
end
