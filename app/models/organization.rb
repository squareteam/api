# Model organizations
class Organization < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :teams
  has_many :user_roles, through: :teams
  has_many :users, through: :user_roles
  # has_many :admins, -> { where(members: { admin: true }) }, through: :members, source: :user


  accepts_nested_attributes_for :users, :teams
end
