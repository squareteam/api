class Project < ActiveRecord::Base

  enum status: [:inprogress, :paused, :validation, :done, :due]

  validates :title, :created_by, presence: true

  belongs_to :creator, foreign_key: 'created_by', class_name: 'User'

  has_many :missions

  has_many :project_accesses, foreign_key: 'project_id'
  has_many :users, -> { where( project_accesses: { object_type: 'User' } ) }, through: :project_accesses
  has_many :organizations, -> { where( project_accesses: { object_type: 'Organization' } ) }, through: :project_accesses

  accepts_nested_attributes_for :users

  attr_accessor :progress
  attr_accessor :metadata

  def progress
    # if self.missions.count
    #   (self.missions.map { |m| m.tasks.where(closed: false).count }.size * 100) / self.missions.count
    # else
      0
    # end
  end

  def metadata
    {
      :documents_count => 0,
      :tasks_count => 0,#self.missions.each { |m| m.tasks.where(closed: false).count },
      :missions_count => self.missions.count,
      :members_count => self.users.count
    }
  end
end