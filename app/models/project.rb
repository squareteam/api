class Project < ActiveRecord::Base

  has_many :missions

  has_many :project_accesses, foreign_key: 'project_id'
  has_many :users, -> { where( project_accesses: { object_type: 'User' } ) }, through: :project_accesses
  has_many :organizations, -> { where( project_accesses: { object_type: 'Organization' } ) }, through: :project_accesses

end
