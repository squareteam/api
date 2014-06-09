class Role < ActiveRecord::Base
  validates_presence_of :name, :permissions
#  validates_uniqueness_of :name, scope: [:team]

  has_many :user_roles
  has_many :users, through: :user_roles
  has_many :teams, through: :user_roles

  def add_permission(permission)
    self.permissions = self.permissions | permission
  end

  def delete_permission(permission)
    self.permissions = self.permissions & ~permission
  end

  def has_permission(permission)
    self.permissions & permission == permission
  end

end

class Role::Permissions
  MANAGE_TEAM           = 0x01
  ADD_PROJECT           = 0x02
  MANAGE_PROJECTS       = 0x04
  ADD_TASK              = 0x08
  MANAGE_TASKS          = 0x10
  ADD_MISSION           = 0x20
  MANAGE_ORGANIZATION   = 0x40
  MANAGE_MISSION        = 0x80
  # XXXX = 0x100
  # XXXX    = 0x200
  # XXXX    = 0x400
  # XXXX    = 0x800
  # XXXX    = 0x1000
end
