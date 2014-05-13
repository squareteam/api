class UserRole < ActiveRecord::Base
  validates_presence_of :user, :role, message: 'api.missing'
  validates_uniqueness_of :user, scope: [:role], message: 'api.already_taken'

  belongs_to :user
  belongs_to :role
end
