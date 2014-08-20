class Project < ActiveRecord::Base

  enum status: [:inprogress, :finished]

  validates :title, :description, :created_by, presence: true

  belongs_to :creator, foreign_key: 'created_by', class_name: 'User'

  has_many :missions

  has_many :project_accesses, foreign_key: 'project_id'
  has_many :users, -> { where( project_accesses: { object_type: 'User' } ) }, through: :project_accesses
  has_many :organizations, -> { where( project_accesses: { object_type: 'Organization' } ) }, through: :project_accesses

  accepts_nested_attributes_for :users
end
