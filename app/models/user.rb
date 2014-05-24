class User < ActiveRecord::Base
  validates_presence_of :email, :pbkdf, :salt, message: 'api.missing'
  validates :email,
            uniqueness: { message: 'api.%{value}_already_taken' },
            format: { with: /\A\w{1}(\w|\.|\+)*\w{1}@\w{1}(\w|\.)*(\.){1}(\w|\.)*\w{1}\Z/, message: 'api.violation' }
  validates :uid,
            uniqueness: { scope: :provider, message: 'api.user_already_exist' }

  has_many :members
  has_many :organizations, :through => :members

  has_many :user_roles
  has_many :roles, :through => :user_roles

  has_many :teams, :through => :roles

  # @ensure !token.blank?
  def oauth_login(token)
    salt, pbkdf = Yodatra::Crypto.generate_pbkdf(token)
    self.pbkdf = pbkdf
    self.salt = salt
    self.save
  end

  # Github oauth information
  # https://developer.github.com/v3/oauth/#scopes
  def self.find_or_create_from_github(auth)
    user = where(auth.slice(:provider, :uid)).first_or_create do |u|
      u.provider = auth.provider
      u.uid = auth.uid
      u.email = auth.info.email
      u.name = auth.info.name
    end
    user.pbkdf = SecureRandom.random_bytes(8) # Invalid as we will recalculate at login time
    user.salt = SecureRandom.random_bytes(8) # Invalid as we will recalculate at login time

    if user.save
      user
    else
      nil
    end
  end

  # Behance oauth information
  # https://www.behance.net/dev/authentication#scopes
  def self.find_or_create_from_behance(auth)
    user = where(auth.slice(:provider, :uid)).first_or_create do |u|
      u.provider = auth.provider
      u.uid = auth.uid
      u.email = auth.info.email
      u.name = auth.info.name
    end
    user.pbkdf = SecureRandom.random_bytes(8) # Invalid as we will recalculate at login time
    user.salt = SecureRandom.random_bytes(8) # Invalid as we will recalculate at login time

    if user.save
      user
    else
      nil
    end
  end
end
