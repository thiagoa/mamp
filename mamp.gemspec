# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','mamp','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'mamp'
  s.version = Mamp::VERSION
  s.author = 'Your Name Here'
  s.email = 'your@email.address.com'
  s.homepage = 'http://your.website.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A description of your project'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = false
  s.bindir = 'bin'
  s.executables << 'mamp'
  s.add_development_dependency('rake')
  s.add_development_dependency('aruba')
  s.add_development_dependency('mocha')
  s.add_runtime_dependency('gli','2.10.0')
end
