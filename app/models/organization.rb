# Model organizations
class Organization < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :members
  has_many :users, through: :members
  has_many :admins, -> { where(members: { admin: true }) }, through: :members, source: :user
end
