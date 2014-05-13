class Organization < ActiveRecord::Base
  validates_presence_of :name, message: 'api.missing'
  validates_uniqueness_of :name, message: 'api.already_taken'

  has_many :members
  has_many :users, through: :members
end
