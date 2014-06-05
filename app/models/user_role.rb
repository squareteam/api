class UserRole < ActiveRecord::Base
  validates_presence_of :user, :role
  validates_uniqueness_of :user, scope: [:role]

  belongs_to :user
  belongs_to :team
  has_many :roles
end
