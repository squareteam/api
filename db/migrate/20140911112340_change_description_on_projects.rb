class ChangeDescriptionOnProjects < ActiveRecord::Migration
  def change
    change_column :projects, :description, :string, :default => ''
  end
end
