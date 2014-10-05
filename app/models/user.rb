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

  has_many :project_accesses, as: :object
  has_many :accessible_projects, through: :project_accesses, source: :project
  # Own projects
  has_many :projects, as: :owner

  accepts_nested_attributes_for :user_roles, :teams

  after_create :say_yo

  class << self
    def easy_new params
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

    def easy_create params
      a_user = easy_new params
      a_user.save
      a_user
    end
  end

  # Given a permission and an organization
  # @returns whether or not the user has the permission in the organization
  # @returns nil if user does not belong to the organization
  def has_permission?(permission, orga)
    perms = orga.user_roles.
      where(user_id: id).
      maximum(:permissions)

    UserRole.has_permission?(perms, permission)
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

  # Omniauth user
  def self.find_for_oauth(auth)
    user = find_or_create_by(uid: auth.uid, provider: auth.provider)

    if user.new_record?
      user.pbkdf = SecureRandom.random_bytes(8) # Invalid as we will recalculate at login time
      user.salt = SecureRandom.random_bytes(8) # Invalid as we will recalculate at login time
    end

    user
  end

  # Github oauth information
  # https://developer.github.com/v3/oauth/#scopes
  def self.find_or_create_from_github(auth)
    user = find_for_oauth(auth)

    if user.new_record?
      user.email = auth.info.email
      user.name = auth.info.name
    end

    user.save
    user
 end

  # Behance oauth information
  # https://www.behance.net/dev/authentication#scopes
  def self.find_or_create_from_behance(auth)
    user = find_for_oauth(auth)

    if user.new_record?
      user.email = auth.info.email
      user.name = auth.info.name
    end

    user.save
    user
  end

  private

  # after_create callback
  # When a User has been created, send an email to say yo
  # Warning: always return true
  def say_yo
    UserMailer.account_creation(self).deliver
    true
  end
end
