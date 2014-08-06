# Model organizations
class Organization < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :teams, dependent: :destroy
  has_many :user_roles, through: :teams, dependent: :destroy
  has_many :users, through: :user_roles
  has_one :admins_team, -> { where(name: 'Admin') }, class_name: 'Team'

  accepts_nested_attributes_for :users, :teams

  after_create :create_admins_team

  # When creating an organization, attach a default team: Admins
  def create_admins_team
    Team.create(name: "Admin", organization: self)
  end

  def add_admin user_or_user_id
    user_id = user_or_user_id.is_a?(User) ? user_or_user_id.id : user_or_user_id
    UserRole.create(
      user_id: user_id,
      team: admins_team,
      permissions: UserRole::Permissions::all
    )
  end

  # Search for an Organization
  # @param params can be a Hash of attributes to search on Organization
  # or a String
  # @param one whether to return one record or a list of possible match
  # @param limit number whether to limit the results or not
  def search(params, one, limit)
    results = []
    if params.is_a? Hash
      matches = []
      params.each do |k,v|
        matches << arel_table[k].matches("%#{v}%")
      end
      results = where(matches.reduce(:or)).limit(limit || one && 1)
    elsif params.is_a? String
      results = where(arel_table[:name].matches("%#{params}%")).limit(limit || one && 1)
    end

    one.nil? ? results : results.first
  end
end
