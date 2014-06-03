class Task < ActiveRecord::Base

   belongs_to :mission

   has_many :task_comments

end