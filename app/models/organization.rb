# Model organizations
class Organization < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :teams, dependent: :destroy
  has_many :user_roles, through: :teams
  has_many :users, through: :user_roles
  has_one :admins_team, -> { where(is_admin: true) }, class_name: 'Team'

  has_many :project_accesses, foreign_key: 'object_id'
  has_many :projects, -> { where( project_accesses: { object_type: 'Organization' } ) }, through: :project_accesses

  accepts_nested_attributes_for :users, :teams

  after_create :create_admins_team

  # When creating an organization, attach a default team: Admins
  def create_admins_team
    Team.create(name: "Admin", organization: self, is_admin: true)
  end

  def add_admin user_or_user_id
    user_id = user_or_user_id.is_a?(User) ? user_or_user_id.id : user_or_user_id
    UserRole.create(
      user_id: user_id,
      team: admins_team,
      permissions: UserRole::Permissions::all
    )
  end

end
