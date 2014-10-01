class Project < ActiveRecord::Base

  enum status: [:inprogress, :paused, :validation, :done, :due]

  validates :title, :owner, presence: true

  has_many :missions

  belongs_to :owner, polymorphic: true
  has_many :project_accesses, foreign_key: 'project_id'
  has_many :users, :through => :project_accesses, :source => :object, :source_type => 'User'
  has_many :organizations, :through => :project_accesses, :source => :object, :source_type => 'Organization'

  after_create :create_owner_access
  accepts_nested_attributes_for :users

  private

  def create_owner_access
    ProjectAccess.create project_id: id, object: owner
  end

  public

  class << self
    # Limit access depending on the current_user
    def limit_read_for(projects, user)
      user_access = ProjectAccess.where(object_type: 'User', object_id: user.id)
      orga_access = ProjectAccess.where(object_type: 'Organization', object_id: user.organizations.pluck(:id))
      user_access = user_access.where_values.reduce(:and)
      orga_access = orga_access.where_values.reduce(:and)
      projects.joins(:project_accesses).where(user_access.or(orga_access)).uniq
    end
    alias :limit_read_all_for :limit_read_for
    alias :limit_delete_for :limit_read_for

  end

  # Defines the progress of a project by calculating the
  # percentage of closed tasks on the total amount of tasks
  def progress
    total_tasks = missions.map(&:tasks).map(&:size).reduce(0, &:+) || 0
    if total_tasks > 0
      total_open_tasks = missions.map(&:open_tasks).map(&:size).reduce(0, &:+)
      100 - total_open_tasks * 100 / total_tasks
    else
      0
    end
  end

  def metadata
    {
      documents_count: 0,
      tasks_count: missions.map(&:open_tasks).map(&:size).reduce(0, &:+),
      missions_count: missions.size,
      members_count: users.size + organizations.map(&:users).map(&:size).reduce(0, &:+)
    }
  end
end
