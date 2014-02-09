class User < ActiveRecord::Base
  validates_presence_of :email, :pbkdf, :salt
  validates :email, :uniqueness => true, format: { with: /\A\w{1}(\w|\.|\+)*\w{1}@\w{1}(\w|\.)*(\.){1}(\w|\.)*\w{1}\Z/ }

  has_many :members
  has_many :organizations, :through => :members

  has_many :user_roles
  has_many :roles, :through => :user_roles

  has_many :teams, :through => :roles
end
