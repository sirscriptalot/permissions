require_relative "./lib/permissions"

Gem::Specification.new do |s|
  s.name     = "permissions"
  s.summary  = "Permissions"
  s.version  = Permissions::VERSION
  s.authors  = ["Steve Weiss"]
  s.email    = ["weissst@mail.gvsu.edu"]
  s.homepage = "https://github.com/sirscriptalot/permissions"
  s.license  = "MIT"
  s.files    = `git ls-files`.split("\n")

  s.add_development_dependency "cutest"
end
