$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ensnare/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ensnare"
  s.version     = Ensnare::VERSION
  s.authors     = ["Andy Hoernecke, Scott Behrens"]
  s.email       = [""]
  s.homepage    = "https://github.com/referefref/ensnare-nx"
  s.summary     = "Ensnare."
  s.description = "Honey traps and trap responses for Ruby on Rails applications (ensnare-nx: the original Ensnare adapted to current Ruby and Rails)."
  s.license     = "BSD-2-Clause"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.required_ruby_version = ">= 3.2"
  s.add_dependency "rails", ">= 7.1", "< 9"

  s.add_development_dependency "sqlite3"

end
