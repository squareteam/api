class Member < ActiveRecord::Base
  validates_presence_of :organization, :user, message: 'api.missing'
  validates_uniqueness_of :organization, scope: [:user], message: 'api.already_taken'

  belongs_to :user
  belongs_to :organization
end
