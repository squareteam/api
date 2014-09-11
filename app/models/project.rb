class Project < ActiveRecord::Base

  enum status: [:inprogress, :paused, :validation, :done, :due]

  validates :title, :created_by, presence: true

  belongs_to :creator, foreign_key: 'created_by', class_name: 'User'

  has_many :missions

  has_many :project_accesses, foreign_key: 'project_id'
  has_many :users, -> { where( project_accesses: { object_type: 'User' } ) }, through: :project_accesses
  has_many :organizations, -> { where( project_accesses: { object_type: 'Organization' } ) }, through: :project_accesses

  accepts_nested_attributes_for :users

  # Defines the progress of a project by calculating the
  # percentage of closed tasks on the total amount of tasks
  def progress
    total_amount_of_tasks = missions.map(&:tasks).map(&:size).reduce(&:+) || 0
    if total_amount_of_tasks > 0
      total_open_tasks = missions.map(&:open_tasks).map(&:size).reduce(&:+)
      100 - total_open_tasks * 100 / total_amount_of_tasks
    else
      100
    end
  end

  def metadata
    {
      documents_count: 0,
      tasks_count: missions.map(&:open_tasks).map(&:size).reduce(&:+),
      missions_count: missions.size,
      members_count: users.size
    }
  end
end
