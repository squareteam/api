class Team < ActiveRecord::Base
  validates_presence_of :name, :organization, message: 'api.missing'
  validates_uniqueness_of :name, scope: [:organization], message: 'api.already_taken'

  has_many :roles
  belongs_to :organization
end
