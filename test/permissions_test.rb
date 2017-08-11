require_relative '../lib/permissions'

class User
  # Include the Authorizable role in any class you would
  # to authorize to do this or that.
  include Permissions::Authorizable

  def initialize(permissions)
    @permissions = permissions
  end

  # Authorizables must provide their own implementation of "permissions".
  # An attr_reader would do.
  def permissions
    @permissions
  end
end

class Command
  attr_reader :user

  def initialize(user)
    @user = user
  end

  # Not provided by the library. An advanced example
  # on how to test things like: "Does an object
  # belong to a particular user?"
  def authorize?(other)
    other.authorize_for?(self.class, self)
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

def assert_authorize(subject, user)
  assert subject.authorize?(user), "#{subject} does not authorize #{user}, it should"
end

def refute_authorize(subject, user)
  assert !subject.authorize?(user), "#{subject} does authorize #{user}, it should not"
end

# Create a Permissions object.
guest_permissions = Permissions.new

# Create permissions, guests are allowed to execute Create.
guest_permissions.for(Create) { true }

# Guests cannot Dpdate or Delete, this is also the default permission.
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

test '#authorize_for?' do
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

test '#authorize?' do
  # Guest
  refute_authorize member_update, guest
  refute_authorize member_delete, guest
  refute_authorize admin_update, guest
  refute_authorize admin_delete, guest

  # Member
  assert_authorize member_update, member
  assert_authorize member_delete, member
  refute_authorize admin_update, member
  refute_authorize admin_delete, member

  # Admin
  assert_authorize member_update, admin
  assert_authorize member_delete, admin
  assert_authorize admin_update, admin
  assert_authorize admin_delete, admin
end
