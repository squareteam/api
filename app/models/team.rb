class Team < ActiveRecord::Base
  validates_presence_of :name, :organization
  validates_uniqueness_of :name, scope: [:organization]

  has_many :user_roles, dependent: :destroy
  has_many :users, -> { select('users.*, user_roles.permissions') }, through: :user_roles
  belongs_to :organization

  accepts_nested_attributes_for :users, :user_roles

  before_destroy :admins_team_cannot_be_destroyed

  def admins_team_cannot_be_destroyed
    return true if organization.nil? || !is_admin

   if organization.admins_team.id == id
      errors[:base] << 'admin team cannot be deleted'
      return false
    end

    true
  end
end
