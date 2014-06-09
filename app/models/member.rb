
class Member < ActiveRecord::Base
  validates_presence_of :organization
  validates_uniqueness_of :organization, scope: [:user]

  belongs_to :user
  belongs_to :organization
end
