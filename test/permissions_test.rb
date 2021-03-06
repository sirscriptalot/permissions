require_relative '../lib/permissions'

class User
  include Permissions::Authorizable

  def initialize(permissions)
    @permissions = permissions
  end
end

class Command
  attr_reader :user

  def initialize(user)
    @user = user
  end
end

class Create < Command
  def execute
    'Create something...'
  end
end

class Update < Command
  def execute
    'Update something...'
  end
end

class Delete < Command
  def execute
    'Delete something...'
  end
end

def assert_authorize_for(user, subject)
  assert user.authorize_for?(subject), "#{user} is not authorized for #{subject}, it should be"
end

def refute_authorize_for(user, subject)
  assert !user.authorize_for?(subject), "#{user} is authorized for #{subject}, it should not be"
end

# Create a Permissions object.
guest_permissions = Permissions.new

# Create permissions, guests are allowed to execute Create.
guest_permissions.for(Create) { true }

# Guests cannot Update or Delete, this is also the default permission.
guest_permissions.for(Update, Delete) { false }

# As a convenience, deep_dup lets you copy existing permissions.
member_permissions = guest_permissions.deep_dup

# Users are allowed to update if they "own" the subject.
member_permissions.for(Update, Delete) { |user, command| user == command.user }

# Specify a custom default permissions to allow admins to do everything.
admin_permissions = Permissions.new { true }

guest = User.new(guest_permissions)

member = User.new(member_permissions)

admin = User.new(admin_permissions)

member_update = Update.new(member) # Commands with "ownership".

member_delete = Delete.new(member)

admin_update = Update.new(admin)

admin_delete = Delete.new(admin)

test do
  # Guest
  assert_authorize_for guest, Create

  refute_authorize_for guest, Update

  refute_authorize_for guest, Delete

  # Member
  assert_authorize_for member, Create

  assert_authorize_for admin, Create

  # Admin
  assert_authorize_for admin, Update

  assert_authorize_for admin, Delete
end
