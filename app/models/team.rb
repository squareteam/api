class Team < ActiveRecord::Base
  validates_presence_of :name, :organization
  validates_uniqueness_of :name, scope: [:organization]

  has_many :user_roles
  belongs_to :organization
end
