class ProjectAccess < ActiveRecord::Base

  belongs_to :project
  belongs_to :user, foreign_key: 'object_id'
  belongs_to :organization, foreign_key: 'object_id'

end
