class Project < ActiveRecord::Base

   has_many :missions

   has_and_belongs_to_many :projects, -> { where( project_accesses: { model_type: 'Organization' } ) }, join_table: 'project_accesses', association_foreign_key: 'model_id'
   has_and_belongs_to_many :projects, -> { where( project_accesses: { model_type: 'User' } ) }, join_table: 'project_accesses', association_foreign_key: 'model_id'

end