class Permissions
  VERSION = '0.1.2'

  module Authorizable
    def permissions
      @permissions
    end

    def authorize_for?(key, *args)
      permissions.authorize?(key, self, *args)
    end
  end

  attr_reader :permissions, :default

  def initialize(permissions = {})
    @permissions = permissions

    if block_given?
      @default = Proc.new
    else
      @default = proc { false }
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
