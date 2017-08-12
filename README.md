# Permissions

A small library for adding permissions to an application for authorization.

## Installation

`gem install permissions`

## Usage

### API

`for(*keys, &block)`: Creates a permission with the given block for each key.

`authorize?(key, *args)`: Runs permission block for key with args.

`deep_dup`: Copies permissions to a new object.

#### Authorizable

`permissions`: Must be implemented by your application.

`authorize_for?(key, *args)` Based off the implemented permissions, calls block with self and args for the given key.

### Example

```ruby
require 'permissions'

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

permissions = Permissions.new

permissions.for(Command) { |user, command| user == command.user }

user = User.new(permissions)

foo = Command.new(user)

bar = Command.new(nil)

user.authorize_for?(Command, foo) # true

user.authorize_for?(Command, bar) # false

permissions.authorize?(Command, user, foo) # true

permissions.authorize?(Command, user, bar) # false
```
