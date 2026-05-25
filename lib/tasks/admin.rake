namespace :admin do
  desc "Grant admin privileges to a user by email"
  task :grant, [ :email ] => :environment do |_t, args|
    email = args[:email]
    abort "Usage: rails admin:grant[email@example.com]" if email.blank?

    user = User.find_by(email_address: email)
    abort "User not found: #{email}" unless user

    if user.admin?
      puts "#{email} is already an admin"
    else
      user.update!(admin: true)
      puts "Granted admin to #{email}"
    end
  end

  desc "Revoke admin privileges from a user by email"
  task :revoke, [ :email ] => :environment do |_t, args|
    email = args[:email]
    abort "Usage: rails admin:revoke[email@example.com]" if email.blank?

    user = User.find_by(email_address: email)
    abort "User not found: #{email}" unless user

    if user.admin?
      user.update!(admin: false)
      puts "Revoked admin from #{email}"
    else
      puts "#{email} is not an admin"
    end
  end
end
