require 'bundler/setup'
require 'rake'
require 'rspec/core/rake_task'

desc 'Default: run specs'
task default: [:clean, :spec]

desc 'Clean up files'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "tmp"
  FileUtils.rm_rf "pkg"
  FileUtils.rm_rf "public"
  Dir.glob("paperclip-*.gem").each { |f| FileUtils.rm f }
end

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end
