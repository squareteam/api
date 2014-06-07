class Team < ActiveRecord::Base
  validates_presence_of :name, :organization
  validates_uniqueness_of :name, scope: [:organization]

  has_many :user_roles
  has_many :roles
  belongs_to :organization

  accepts_nested_attributes_for :user_roles, :roles
end
