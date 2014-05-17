# To be deleted after migration done
namespace :db do
  desc 'Migrate provider data on Users'
  task :migrate_existing_users do
    require 'digest/sha1'

    User.find_each do |user|
      user.provider = 'squareteam'
      user.uid = Digest::SHA1.hexdigest user.email
    end
  end
end
