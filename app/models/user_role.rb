class UserRole < ActiveRecord::Base
  validates_presence_of :user, :team, :permissions
  validates_uniqueness_of :user, scope: [:team]

  belongs_to :user
  belongs_to :team

  class << self
    def add_permission(permissions, permission)
      permissions | permission
    end

    def delete_permission(permissions, permission)
      permissions & ~permission
    end

    def has_permission?(permissions, permission)
      permissions & permission == permission
    end
  end

  def add_permission(permission)
    self.permissions = UserRole.add_permission(permissions, permission)
  end

  def delete_permission(permission)
    self.permissions = UserRole.delete_permission(permissions, permission)
  end

  def has_permission?(permission)
    self.permissions = UserRole.has_permission?(permissions, permission)
  end
end

class UserRole::Permissions
  MANAGE_TEAM           = 0x01
  ADD_PROJECT           = 0x02
  MANAGE_PROJECTS       = 0x04
  ADD_TASK              = 0x08
  MANAGE_TASKS          = 0x10
  ADD_MISSION           = 0x20
  MANAGE_ORGANIZATION   = 0x40
  MANAGE_MISSION        = 0x80

  # XXXX    = 0x100
  # XXXX    = 0x200
  # XXXX    = 0x400
  # XXXX    = 0x800
  # XXXX    = 0x1000


  def self.all
    MANAGE_TEAM | ADD_PROJECT | MANAGE_PROJECTS | ADD_TASK | MANAGE_TASKS | ADD_MISSION | MANAGE_ORGANIZATION | MANAGE_MISSION
  end
end
