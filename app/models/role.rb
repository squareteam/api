class Role < ActiveRecord::Base
  validates_presence_of :name, :permissions, :team, message: 'api.{{value}}_missing'
  validates_uniqueness_of :name, scope: [:team], message: 'api.{{value}}_already_taken'

  belongs_to :team

  has_many :user_roles
  has_many :users, through: :user_roles
end
