# -*- encoding: utf-8 -*-
# stub: heroku-deflater 0.6.2 ruby lib

Gem::Specification.new do |s|
  s.name = "heroku-deflater"
  s.version = "0.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Roman Shterenzon"]
  s.date = "2015-11-03"
  s.description = "Deflate assets on heroku"
  s.email = "romanbsd@yahoo.com"
  s.extra_rdoc_files = ["LICENSE.txt", "README.md"]
  s.files = ["LICENSE.txt", "README.md"]
  s.homepage = "http://github.com/romanbsd/heroku-deflater"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.5.1"
  s.summary = "Deflate assets on heroku"

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.4.5"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 1.4.5"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.4.5"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
  end
end
