class Permissions
  VERSION = '0.1.1'

  module Authorizable
    def permissions
      raise NotImplementedError
    end

    def authorize_for?(key, *args)
      permissions.authorize?(key, self, *args)
    end
  end

  attr_reader :permissions, :default

  def initialize(permissions = {}, &default)
    @permissions = permissions

    if block_given?
      @default = default
    else
      @default = lambda { false }
    end
  end

  def for(*keys, &block)
    keys.each { |key| permissions[key] = block }
  end

  def authorize?(key, *args)
    permissions.fetch(key, default).call(*args)
  end

  def deep_dup(initial_permissions = {})
    Permissions.new(initial_permissions.merge(permissions)) { default }
  end
end
