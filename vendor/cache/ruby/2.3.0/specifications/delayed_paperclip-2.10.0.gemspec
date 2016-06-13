# -*- encoding: utf-8 -*-
# stub: delayed_paperclip 2.10.0 ruby lib

Gem::Specification.new do |s|
  s.name = "delayed_paperclip"
  s.version = "2.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jesse Storimer", "Bert Goethals", "James Gifford", "Scott Carleton"]
  s.date = "2016-05-03"
  s.description = "Process your Paperclip attachments in the background with DelayedJob, Resque, Sidekiq or your own processor."
  s.email = ["james@jamesrgifford.com", "scott@artsicle.com"]
  s.homepage = "http://github.com/jrgifford/delayed_paperclip"
  s.rubygems_version = "2.5.1"
  s.summary = "Process your Paperclip attachments in the background."

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<paperclip>, [">= 3.3"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["< 3.0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<delayed_job>, [">= 0"])
      s.add_development_dependency(%q<delayed_job_active_record>, [">= 0"])
      s.add_development_dependency(%q<resque>, [">= 0"])
      s.add_development_dependency(%q<sidekiq>, [">= 4.0"])
      s.add_development_dependency(%q<appraisal>, [">= 0"])
      s.add_development_dependency(%q<rake>, ["~> 10.5.0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<railties>, [">= 0"])
      s.add_development_dependency(%q<fakeredis>, [">= 0"])
    else
      s.add_dependency(%q<paperclip>, [">= 3.3"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<rspec>, ["< 3.0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<delayed_job>, [">= 0"])
      s.add_dependency(%q<delayed_job_active_record>, [">= 0"])
      s.add_dependency(%q<resque>, [">= 0"])
      s.add_dependency(%q<sidekiq>, [">= 4.0"])
      s.add_dependency(%q<appraisal>, [">= 0"])
      s.add_dependency(%q<rake>, ["~> 10.5.0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<railties>, [">= 0"])
      s.add_dependency(%q<fakeredis>, [">= 0"])
    end
  else
    s.add_dependency(%q<paperclip>, [">= 3.3"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<rspec>, ["< 3.0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<delayed_job>, [">= 0"])
    s.add_dependency(%q<delayed_job_active_record>, [">= 0"])
    s.add_dependency(%q<resque>, [">= 0"])
    s.add_dependency(%q<sidekiq>, [">= 4.0"])
    s.add_dependency(%q<appraisal>, [">= 0"])
    s.add_dependency(%q<rake>, ["~> 10.5.0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<railties>, [">= 0"])
    s.add_dependency(%q<fakeredis>, [">= 0"])
  end
end
