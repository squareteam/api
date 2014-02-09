class Role < ActiveRecord::Base
  validates_presence_of :name, :permissions, :team
  validates_uniqueness_of :name, :scope => [:team]

  belongs_to :team

  has_many :user_roles
  has_many :users, :through => :user_roles
end
