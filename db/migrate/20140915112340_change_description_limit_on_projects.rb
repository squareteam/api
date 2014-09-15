class ChangeDescriptionLimitOnProjects < ActiveRecord::Migration
  def change
    change_column :projects, :description, :text, :limit => 5000, :default => nil, :null => true
  end
end
