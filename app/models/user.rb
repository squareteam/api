class User < ActiveRecord::Base
  validates_presence_of :email, :pbkdf, :salt, message: 'api.missing'
  validates :email,
            uniqueness: { message: 'api.%{value}_already_taken' },
            format: { with: /\A\w{1}(\w|\.|\+)*\w{1}@\w{1}(\w|\.)*(\.){1}(\w|\.)*\w{1}\Z/, message: 'api.violation' }

  has_many :members
  has_many :organizations, :through => :members

  has_many :user_roles
  has_many :roles, :through => :user_roles

  has_many :teams, :through => :roles
end
