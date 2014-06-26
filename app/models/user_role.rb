class UserRole < ActiveRecord::Base
  validates_presence_of :user, :role
  validates_uniqueness_of :user, scope: [:team]

  belongs_to :user
  belongs_to :team
  belongs_to :role
end
