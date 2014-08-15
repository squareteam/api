class User < ActiveRecord::Base
  validates_presence_of :email, :pbkdf, :salt
  validates :email,
            uniqueness: true,
            format: { with: /\A\w{1}(\w|\.|\+)*\w{1}@\w{1}(\w|\.)*(\.){1}(\w|\.)*\w{1}\Z/, message: 'api.violation' }
  validates :uid,
            uniqueness: { scope: :provider }

  has_many :user_roles
  has_many :teams, :through => :user_roles
  has_many :organizations, -> { uniq }, :through => :teams

  accepts_nested_attributes_for :user_roles, :teams

  def self.easy_new params
    salt, pbkdf = Yodatra::Crypto.generate_pbkdf(params[:password])
    email = params[:identifier]||params[:email]
    uid = email.nil? ? nil : Digest::SHA1.hexdigest(email)
    User.new(
      :uid => uid,
      :provider => 'squareteam',
      :email => email,
      :pbkdf => pbkdf,
      :salt => salt,
      :name => params[:name]
    )
  end

  def self.easy_create params
    a_user = easy_new params
    a_user.save
    a_user
  end

  # Fully change a password
  #   By regenerate salt1 and pbkdf and
  #   flushing associated keys in Redis
  # @ensure !token.blank?
  def change_password(token)
    cache = Cache.new
    cache.rm_cache "#{self.email}:SALT2"
    cache.rm_cache "#{self.email}:TOKEN"

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

    if user.new_record?
      user.pbkdf = SecureRandom.random_bytes(8) # Invalid as we will recalculate at login time
      user.salt = SecureRandom.random_bytes(8) # Invalid as we will recalculate at login time
    end

    user.save
    user
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
