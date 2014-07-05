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
    self.admin_team_id = admins_team.id
    self.save
  end


  accepts_nested_attributes_for :users, :teams
end
