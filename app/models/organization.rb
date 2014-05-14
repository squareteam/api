class Organization < ActiveRecord::Base
  validates_presence_of :name, message: 'api.{{value}}_missing'
  validates_uniqueness_of :name, message: 'api.{{value}}_already_taken'

  has_many :members
  has_many :users, through: :members
end
