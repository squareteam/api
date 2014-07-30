class User < ActiveRecord::Base
  validates_presence_of :email, :pbkdf, :salt
  validates :email,
            uniqueness: true,
            format: { with: /\A\w{1}(\w|\.|\+)*\w{1}@\w{1}(\w|\.)*(\.){1}(\w|\.)*\w{1}\Z/, message: 'api.violation' }
  validates :uid,
            uniqueness: { scope: :provider }

  has_many :user_roles
  has_many :teams, :through => :user_roles
  has_many :organizations, :through => :teams

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
end
