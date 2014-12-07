require 'github/markup'

#
# Modeling a Project within Squareteam
#
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

  # Format description
  def description_md
    GitHub::Markup.render '.md', read_attribute(:description) unless read_attribute(:description).nil?
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
