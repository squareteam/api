# Model organizations
class Organization < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :teams
  has_many :user_roles, through: :teams
  has_many :users, through: :user_roles
  # has_many :admins, -> { where(members: { admin: true }) }, through: :members, source: :user

  after_create :create_admins_team


  # We creating a organization, attach 2 defaults teams : Admins & Members
  def create_admins_team
    # Create Admin team with all rights
    admins_team  = Team.create(name: "Admin", organization: self)
    admin_role   = Role.create(
      name: "Admin",
      permissions: Role::Permissions::all,
    )

    # Create member team
    members_team = Team.create(name: "Members", organization: self)
    Role.create(name: "Members", permissions: Role::Permissions::ADD_TASK)
  end


  accepts_nested_attributes_for :users, :teams
end
