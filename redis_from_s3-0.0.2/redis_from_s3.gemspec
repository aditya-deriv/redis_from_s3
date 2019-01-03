# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','redis_from_s3','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'redis_from_s3'
  s.version = Redis_from_S3::VERSION
  s.author = 'Kostiantyn Lysenko'
  s.email = 'gshaud@gmail.com'
  s.homepage = 'http://jakshi.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Redis to S3 dumper'
  s.description = 'Download Redis keys dump from AWS S3'
  s.licenses = ["Apache License, Version 2.0"]
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'redis_from_s3'
  s.add_development_dependency('rake')
  s.add_runtime_dependency('settingslogic')
  s.add_runtime_dependency('aws-sdk')
  s.add_runtime_dependency('trollop')
end
