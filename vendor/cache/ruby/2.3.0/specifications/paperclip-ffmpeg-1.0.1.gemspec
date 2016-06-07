# -*- encoding: utf-8 -*-
# stub: paperclip-ffmpeg 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "paperclip-ffmpeg"
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Omar Abdel-Wahab"]
  s.date = "2013-10-27"
  s.description = "Process your attachments with FFMPEG"
  s.email = ["owahab@gmail.com"]
  s.homepage = "http://github.com/owahab/paperclip-ffmpeg"
  s.licenses = ["MIT"]
  s.rubyforge_project = "paperclip-ffmpeg"
  s.rubygems_version = "2.5.1"
  s.summary = "Process your attachments with FFMPEG"

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<paperclip>, [">= 2.5.2"])
    else
      s.add_dependency(%q<paperclip>, [">= 2.5.2"])
    end
  else
    s.add_dependency(%q<paperclip>, [">= 2.5.2"])
  end
end
