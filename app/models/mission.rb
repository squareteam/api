require 'github/markup'

#
# Missions belongs to projects
#
class Mission < ActiveRecord::Base

  enum status: [:inprogress, :paused, :validation, :done, :due]

  validates :title, :creator, :project, presence: true

  belongs_to :creator, foreign_key: 'created_by', class_name: 'User'

  belongs_to :project
  has_many :tasks
  has_many :open_tasks, -> { where(closed: false) }, class_name: 'Task'

  public

  # Format description
  def description_md
    GitHub::Markup.render '.md', read_attribute(:description) unless read_attribute(:description).nil?
  end

  # Defines the progress of a project by calculating the
  # percentage of closed tasks on the total amount of tasks
  def progress
    total_amount_of_tasks = tasks.count
    if total_amount_of_tasks > 0
      total_open_tasks = open_tasks.count
      100 - total_open_tasks * 100 / total_amount_of_tasks
    else
      0
    end
  end

  def metadata
    {
      documents_count: 0,
      tasks_count: open_tasks.count,
      members_count: 0 #users.size
    }
  end

end
