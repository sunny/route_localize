$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "route_localize/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "route_localize"
  s.version     = RouteLocalize::VERSION
  s.authors     = ["Sunny Ripert"]
  s.email       = ["sunny@sunfox.org"]
  s.homepage    = "http://github.com/sunny/route_localize"
  s.summary     = "Rails 4 engine to translate routes."
  s.description = "Rails 4 engine to to translate routes using locale files and subdomains."

  s.files = Dir["{app,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
end
