class Mission < ActiveRecord::Base
  belongs_to :project
  has_many :tasks
  has_many :open_tasks, -> { where(closed: false) }, class_name: 'Task'
end
