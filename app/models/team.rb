class Team < ActiveRecord::Base
  validates_presence_of :name, :organization
  validates_uniqueness_of :name, scope: [:organization]

  has_many :user_roles
  has_many :users, through: :user_roles
  belongs_to :organization

  accepts_nested_attributes_for :users, :user_roles

  before_destroy :admin_team_cannot_be_destroyed

  def admin_team_cannot_be_destroyed
    if self.organization.admin_team_id == self.id
      errors[:base] << "admin team cannot be deleted"
      return false
    end
    return true
  end
end
